import 'package:simplegamelib/simplegamelib.dart';
import 'dart:html';
import 'dart:math';

class Shootem {
  Game game = new Game("Shootemdown", '#Surface');

  Sprite player;
  SpriteGroup invaders;
  SpriteGroup bullets;
  SpriteGroup badBullets;
  AudioBank sounds = new AudioBank();
  final _random = new Random();

  Shootem() {
    sounds.load('fire', 'snd/1.wav');
    sounds.load('hurt', 'snd/hurt.wav');
    player = game.createSprite("img/ship.png", 48, 48);

    invaders = new SpriteGroup();
    bullets = new SpriteGroup();
    badBullets = new SpriteGroup();
    for (int i = 0; i < 9; i++) {
      Sprite inv = game.createSprite("img/inv1.png", 48, 48);
      invaders.add(inv);

      inv
        ..position = new Point(10 + i * 50, 0)
        ..movement = Movements.east;
    }

    game
      ..renderer.liveBackground.color = "#000000"
      ..renderer.limits = new Rectangle(0, 0, 640, 480)
      ..setUpKeys()
      ..player.sprite = player;

    setUpKeys();

    player
      ..position = new Point(296, 401)
      ..speed = 4
      ..limits = new Rectangle(0, 380, 640, 100);

    game.customUpdate = update;
    game.start();
  }

  void update() {
    bool reverse = false;
    invaders.sprites.forEach((Sprite inv) {
      if (inv.x > 600 || inv.x < 0) reverse = true;
    });
    if (reverse) {
      invaders.sprites.forEach((Sprite inv) {
        inv.movement = new Point(inv.movement.x * -1, 0);
        inv.y += 10;
      });
    }

    // Good bullets
    bullets.sprites.forEach((Sprite bullet) {
      invaders.sprites.forEach((Sprite inv) {
        if (inv.detectCollision(bullet)) {
          inv.alive = false;
          bullet.alive = false;
          sounds.play('hurt');
        }
      });
    });

    // Bad bullets;
    invaderFire();

    badBullets.sprites.forEach((Sprite bullet) {
      if (player.detectCollision(bullet)) {
        player.alive = false;
        bullet.alive = false;
        sounds.play('hurt');
      }
    });
    invaders.removeDead();
    bullets.removeDead();
  }

  invaderFire() {
    if (invaders.length == 0 || _random.nextInt(100) != 99) return;
    Sprite bad = game.createSprite("img/badbullet.png", 8, 48);
    badBullets.add(bad);
    int invaderID = _random.nextInt(invaders.length);
    bad
      ..position = new Point(invaders.sprites[invaderID].x + 24,
          invaders.sprites[invaderID].y + 20)
      ..movement = Movements.south
      ..speed = 5;
    sounds.play('fire');
  }

  playerFire() {
    Sprite b = game.createSprite("img/goodbullet.png", 8, 48);
    bullets.add(b);
    b
      ..position = new Point(player.x + 24, player.y)
      ..movement = Movements.north
      ..speed = 5;
    sounds.play('fire');
  }

  void setUpKeys() {
    window.onKeyDown.listen((KeyboardEvent e) {});

    window.onKeyUp.listen((KeyboardEvent e) {
      if (e.keyCode == 88) {
        playerFire();
      }
    });
  }
}
