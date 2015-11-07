import 'package:simplegamelib/simplegamelib.dart';
import 'dart:html';
import 'dart:math';

class MutablePoint {
  int x;
  int y;
  MutablePoint(this.x, this.y);
}

class Starfield {

  int speed = 0;
  int count = 0;
  int x = 0;
  int y = 0;
  int width = 640;
  int height = 480;

  List<MutablePoint> stars;
  CanvasRenderingContext2D surface;

  Starfield(this.x, this.y, this.width, this.height, this.count, this.speed,
      this.surface) {
    stars = new List<MutablePoint>();
    DateTime now = new DateTime.now();
    Random rng = new Random(now.millisecondsSinceEpoch);
    while (this.count > stars.length) stars
        .add(new MutablePoint(rng.nextInt(width), rng.nextInt(height)));
  }

  void draw() {
    String temp = surface.fillStyle;
    surface.fillStyle = 'white';
    for (MutablePoint star
        in stars) this.surface.fillRect(star.x, star.y, 1, 1);
    surface.fillStyle = temp;
    update();
  }

  void update() {
    stars.forEach((MutablePoint star) {
      star.x += speed;
      if (star.x > width) star.x = 0;
      else if (star.x < 0) star.x = width;
    });
  }
}
