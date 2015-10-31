import 'package:simplegamelib/simplegamelib.dart';
import 'dart:html';
import 'dart:math';

/// Core class for left-right shooter game.
class ShootEmDown {
  Game game = new Game("Shootemdown", '#Surface');

  Sprite playerShip;
  SpriteGroup invaders;
  SpriteGroup goodBullets;
  SpriteGroup badBullets;
  AudioBank sounds = new AudioBank();
  final _random = new Random();

  /// Create a crowd of invaders.
  buildMob() {
    invaders = new SpriteGroup();
    goodBullets = new SpriteGroup();
    badBullets = new SpriteGroup();

    for (int k = 0; k < 4; k++) {
      for (int i = 0; i < 9; i++) {
        Sprite inv = game.createSprite("img/inv1.png", 48, 48);
        inv.setDyingImage("img/hitinv1.png");
        invaders.add(inv);

        inv
          ..position = new Point(10 + i * 50, k * 45)
          ..movement = Movements.east
          ..cyclesToDie = 100;
      }
    }
  }

  /// Reset player's [Sprite].
  resetPlayer() {
    playerShip
      ..position = new Point(296, 401)
      ..speed = 4
      ..limits = new Rectangle(0, 380, 640, 100);
    updateScorePanel(game.player);
  }

  /// Game initialisation
  ShootEmDown() {
    sounds.load('fire', 'snd/1.wav');
    sounds.load('hurt', 'snd/hurt.wav');

    playerShip = game.createSprite("img/ship.png", 48, 48);
    playerShip.setDyingImage("img/hitship.png");

    game
      ..renderer.liveBackground.color = "#000000"
      ..renderer.limits = new Rectangle(0, 0, 640, 480)
      ..setUpKeys()
      ..player = new Player.withNotifications(updateScorePanel)
      ..player.sprite = playerShip;

    setUpKeys();
    resetPlayer();
    game.customUpdate = update;

    // Level 1.
    buildMob();

    game.start();
  }

  /// Update all sprites and check for collisions.
  void update() {
    // Invader LtoR movement.
    bool reverse = false;
    invaders.sprites.forEach((Sprite inv) {
      if (inv.x > 600 || inv.x < 0) reverse = true;
    });
    if (reverse) {
      invaders.sprites.forEach((Sprite inv) {
        if (!inv.dying) {
          inv.movement = reverseDirection(inv.movement);
          inv.y += 10;
        }
      });
    }

    // Good bullets
    goodBullets.sprites.forEach((Sprite bullet) {
      invaders.sprites.forEach((Sprite inv) {
        if (bullet.alive && inv.detectCollision(bullet)) {
          //inv.alive = false;
          inv
            ..dying = true
            ..movement = Movements.north
            ..speed = 12;
          bullet.alive = false;
          sounds.play('hurt');
          game.player.score += 10;
        }
      });
      if (bullet.y < 0) bullet.alive = false;
    });

    badBullets.sprites.forEach((Sprite bullet) {
      if (playerShip.detectCollision(bullet)) {
        playerShip.dying = true;
        playerShip.movement = Movements.none;
        bullet.alive = false;
        sounds.play('hurt');
        game.player.lives -= 1;
        badBullets.reset();
      }
      if (bullet.y > 480) bullet.alive = false;
    });
    invaders.removeDead();
    goodBullets.removeDead();
    badBullets.removeDead();

    if (playerShip.dying || !playerShip.alive){
      if(game.player.isReadyToRespawn())
      {
        playerShip..dying = false
                  ..alive = true;
        game.spriteGroup.add(playerShip);
        print("Respawn!");
        //game.player.sprite = playerShip;
      }
    }

    // Bad bullets;
    invaderFire();
  }

  /// Launch a bullet from the [Invaders]'s [Sprite].
  invaderFire() {
    if (playerShip.alive == false ||
        playerShip.dying == true ||
        invaders.length == 0 ||
        _random.nextInt(20) != 10) return;
    Sprite bad = game.createSprite("img/badbullet.png", 8, 8);
    badBullets.add(bad);
    int invaderID = _random.nextInt(invaders.length);
    bad
      ..position = new Point(invaders.sprites[invaderID].x + 24,
          invaders.sprites[invaderID].y + 20)
      ..movement = Movements.south
      ..speed = 5;
    sounds.play('fire');
  }

  /// Launch a bullet from the [Player]'s [Sprite].
  playerFire() {
    if (playerShip.alive == false || playerShip.dying == true) return;
    Sprite b = game.createSprite("img/goodbullet.png", 8, 8);
    goodBullets.add(b);
    b
      ..position = new Point(playerShip.x + 10, playerShip.y)
      ..movement = Movements.north
      ..speed = 5;
    sounds.play('fire');
  }

  /// Set fire button.
  void setUpKeys() {
    window.onKeyDown.listen((KeyboardEvent e) {});

    window.onKeyUp.listen((KeyboardEvent e) {
      if (e.keyCode == 88) {
        if (goodBullets.length < 3) playerFire();
      }
    });
  }

  void updateScorePanel(Player p1) {
    DivElement statusPanel = querySelector("#gameStatus");
    statusPanel.innerHtml = "Score : ${p1.score} Lives ${p1.lives}";
  }
}
