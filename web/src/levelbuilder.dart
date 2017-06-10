import 'package:simplegamelib/simplegamelib.dart';
import 'dart:math';

class LevelBuilder {

  final _random = new Random();

  SpriteGroup invaders;

  Game game;
  bool reverse = false;

  LevelBuilder() {}

  buildLevel(int i) {
    if (i == 1) {
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
    }
    else if (i == 2) {
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
          ..setPosition((10 + i * 50), -149)
          ..movement = Movements.south;
      }

      for (int i = 0; i < 9; i++) {
        inv = createInvader(3);
        inv
          ..setPosition(10 + i * 55, -299)
          ..movement = Movements.south;
      }

      for (int i = 0; i < 9; i++) {
        inv = createInvader(_random.nextInt(2) + 1);
        inv
          ..setPosition(10 + i * 55, -349)
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

  void resetLevel() {

  }

}