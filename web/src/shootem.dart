import 'package:simplegamelib/simplegamelib.dart';
import 'dart:html';
import 'dart:math';
import 'prompts.dart';
import 'starfield.dart';
import 'levelbuilder.dart';

class ShootEmDown {
  final Game game = new Game("Shootemdown", '#Surface');

  final SpriteGroup invaders = new SpriteGroup();
  final SpriteGroup goodBullets = new SpriteGroup();
  final SpriteGroup badBullets = new SpriteGroup();
  final AudioBank sounds = new AudioBank();
  final LevelBuilder levelBuilder = new LevelBuilder();
  final _random = new Random();

  Sprite playerShip;
  Starfield stars;
  Starfield starsMid;

  ShootEmDown() {
    levelBuilder.invaders = invaders;
    levelBuilder.game = game;

    playerShip = game.createSprite("img/ship.png", 24, 20);
    playerShip.setDyingImage("img/hitship.png");

    sounds..load('fire', 'snd/1.wav')..load('hurt', 'snd/hurt.wav');

    game
      ..renderer.liveBackground.color = "#000000"
      ..renderer.limits = new Rectangle(0, 0, 640, 480)
      ..setUpKeys()
      ..player = new Player.withNotifications(updateScorePanel)
      ..player.sprite = playerShip;

    createStarfields();
    setUpKeys();
    game
      ..customUpdate = update
      ..renderer.liveBackground.postCustomDraw = this.postCustomDraw;
    start();
  }

  void createStarfields() {
    stars = new Starfield(
        0,
        0,
        640,
        480,
        33,
        2,
        game.renderer.canvas);
    starsMid = new Starfield(
        0,
        0,
        640,
        480,
        23,
        3,
        game.renderer.canvas);
  }

  /// Create a crowd of invaders.
  void progressToNextLevel() {
    levelBuilder.level++;
    goodBullets.reset();
    badBullets.reset();
    levelBuilder.buildLevel();
  }

  /// Reset player's [Sprite] to start or resume a level.
  void resetPlayer() {
    playerShip
      ..setPosition(296, 401)
      ..speed = 4
      ..limits = new Rectangle(0, 380, 640, 100);
    updateScorePanel(game.player);
  }

  /// Update all sprites and check for collisions.
  void update() {
    handleInvaderMovement();

    handlePlayerBullets();

    handleInvaderBullets();

    speedUpInvadersWhenDiminished();

    clearDeadSprites();

    handlePlayerLifecycle();

    invaderFire();
  }

  void handleInvaderMovement() {
    bool reverse = false;
    invaders.sprites.forEach((Sprite inv) {
      if (inv.x > 600 || inv.x < 0) reverse = true;
      if (inv.y < -500) inv.alive = false;
    });

    if (reverse && levelBuilder.reverse) {
      invaders.sprites.forEach((Sprite inv) {
        if (!inv.dying) {
          inv.movement = reverseDirection(inv.movement);
          inv.y += 10;
        }
      });
    }
    else {
      invaders.sprites.forEach((Sprite inv) {
        if (inv.y > 480) {
          inv.y = inv.y - 555;
          if (inv.speed == 1) inv.speed = 2;
          inv.x = 640 - inv.x;
        }
      });
    }
  }

  void speedUpInvadersWhenDiminished() {
    if (invaders.length == 6) {
      if (invaders.sprites[0].speed == 1) {
        invaders.sprites.forEach((Sprite inv) {
          inv.speed = inv.speed + 2;
        });
      }
    }
  }

  void clearDeadSprites() {
    invaders.removeDead();
    goodBullets.removeDead();
    badBullets.removeDead();

    if (invaders.length == 0) {
      levelBuilder.level++;
      progressToNextLevel();
    }
  }

  void handlePlayerLifecycle() {
    if (playerShip.dying || !playerShip.alive) {
      if (game.player.lives < 0) {
        showGameOver();
        game.stop();
      } else if (game.player.isReadyToRespawn()) {
        playerShip
          ..dying = false
          ..alive = true;
        game.spriteGroup
            .add(playerShip); // SpriteGroup update removes dead sprites.
        hideGetReady();
      }
    }
  }

  void handleInvaderBullets() {
    badBullets.sprites.forEach((Sprite bullet) {
      if (playerShip.detectCollision(bullet)) {
        playerShip.dying = true;
        playerShip.movement = Movements.none;

        bullet.alive = false;
        sounds.play('hurt');
        game.player.lives -= 1;
        if (game.player.lives > -1) {
          showGetReady();
        }
      }
      if (bullet.y > 480) bullet.alive = false;
    });
  }

  void handlePlayerBullets() {
    goodBullets.sprites.forEach((Sprite bullet) {
      invaders.sprites.forEach((Sprite inv) {
        if (bullet.alive && inv.detectCollision(bullet)) {
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
  }

  /// Launch a bullet from the [Invaders]'s [Sprite].
  void invaderFire() {
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
  void playerFire() {
    if (game.player.lives < 0) {
      game.player.lives = 1;
      start();
      return;
    }

    if (playerShip.alive == false || playerShip.dying == true) return;

    createGoodBullet()
      ..setPosition(playerShip.x + 10, playerShip.y)
      ..movement = Movements.north;

    sounds.play('fire');
  }

  void start() {
    resetPlayer();
    game.spriteGroup.reset();
    game.spriteGroup.add(playerShip);
    playerShip.alive = true;
    game.player.reset();
    goodBullets.reset();

    // Level 1.
    levelBuilder.level = 0;
    progressToNextLevel();

    hideGameOver();
    game.start();
  }

  /// Set fire button.
  void setUpKeys() {
    window.onKeyDown.listen((KeyboardEvent e) {});

    window.onKeyUp.listen((KeyboardEvent e) {
      if (e.keyCode == 88) {
        if (goodBullets.length < 6) playerFire();
      } else if (e.keyCode == 67 && goodBullets.length < 4) {
        playerFireAlternate();
      }
    });
  }

  /// Update the HTML page the the game status.
  void updateScorePanel(Player p1) {
    DivElement statusPanel = querySelector("#gameStatus");
    int lives = max(p1.lives, 0);
    statusPanel.innerHtml = "Score : ${p1.score} Lives ${lives}";
  }

  /// Draw the [Starfield] layers.
  void postCustomDraw(CanvasRenderingContext2D canvas) {
    stars.draw();
    starsMid.draw();
  }

  void playerFireAlternate() {
    if (game.player.lives < 0) {
      game.player.lives = 1;
      start();
      return;
    }

    if (playerShip.alive == false || playerShip.dying == true) return;

    createGoodBullet()
      ..setPosition(playerShip.x + 10, playerShip.y)
      ..movement = Movements.northwest;
    createGoodBullet()
      ..setPosition(playerShip.x + 10, playerShip.y)
      ..movement = Movements.north;
    createGoodBullet()
      ..setPosition(playerShip.x + 10, playerShip.y)
      ..movement = Movements.northeast;

    sounds.play('fire');
  }

  Sprite createGoodBullet() {
    Sprite a = game.createSprite("img/goodbullet.png", 8, 8);
    a..speed = 6;
    goodBullets.add(a);
    return a;
  }
}
