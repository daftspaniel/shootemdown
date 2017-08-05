import 'package:simplegamelib/simplegamelib.dart';
import 'dart:math';

class LevelBuilder {
  final _random = new Random();

  SpriteGroup invaders;

  Game game;
  bool reverse = false;
  int level = 4;

  LevelBuilder() {}

  buildLevel() {
    if (level == 1) {
      reverse = true;
      invaders.reset();
      Sprite inv;
      for (int k = 0; k < 4; k++) {
        for (int i = 0; i < 9; i++) {
          int g = (k + 1);
          if (g > 3) g = 1;
          inv = createInvader(g);

          inv
            ..setPosition(10 + i * 50, k * 49)
            ..movement = Movements.east;
        }
      }
    } else if (level == 2) {
      reverse = false;
      invaders.reset();
      Sprite inv;

      for (int i = 0; i < 9; i++) {
        inv = createInvader();

        inv
          ..setPosition(10 + i * 50, 49)
          ..movement = Movements.south;
      }

      for (int i = 0; i < 9; i++) {
        inv = createInvader(2);
        inv
          ..setPosition(10 + i * 50, -149)
          ..movement = Movements.south;

        inv = createInvader(3);
        inv
          ..setPosition(15 + i * 50, -299)
          ..movement = Movements.south;

        inv = createInvader(_random.nextInt(2) + 1);
        inv
          ..setPosition(20 + i * 50, -349)
          ..movement = Movements.south;
      }
    } else if (level == 3) {
      reverse = false;
      invaders.reset();
      Sprite inv;

      for (int i = 0; i < 9; i++) {
        inv = createInvader();

        inv
          ..setPosition((10 - i) * -50, -400 + (i * 50))
          ..movement = Movements.southeast;
      }
    } else if (level == 4) {
      reverse = false;
      invaders.reset();
      Sprite inv;

      for (int i = 0; i < 9; i++) {
        inv = createInvader();

        inv
          ..setPosition(_random.nextInt(10) *30, -400 + (_random.nextInt(10) * i * 50))
          ..movement = Movements.south;
      }
    }
  }

  Sprite createInvader([int invaderType = 1]) {
    Sprite inv = game.createSprite("img/inv$invaderType.png", 48, 48);
    invaders.add(inv);
    inv
      ..cyclesToDie = 100
      ..setDyingImage("img/hitinv1.png");
    return inv;
  }

  void resetLevel() {}
}
