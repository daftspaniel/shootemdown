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
  int direction = 0;

  Random rng = new Random();
  List<MutablePoint> stars = new List<MutablePoint>();
  CanvasRenderingContext2D surface;

  Starfield(this.x, this.y, this.width, this.height, this.count, this.speed,
      this.surface) {

    while (this.count > stars.length) stars
        .add(new MutablePoint(rng.nextInt(width), rng.nextInt(height)));
  }

  void draw() {
    String temp = surface.fillStyle;
    surface.fillStyle = 'white';
    for (MutablePoint star in stars)
      this.surface.fillRect(star.x, star.y, 1, 1);
    surface.fillStyle = temp;
    update();
    if (rng.nextInt(1000) == 1) direction = 1 - direction;
  }

  void update() {
    if (direction == 1) {
      stars.forEach((MutablePoint star) {
        star.x += speed;
        if (star.x > width)
          star.x = 0;
        else if (star.x < 0) star.x = width;
      });
    } else {
      stars.forEach((MutablePoint star) {
        star.y += speed;
        if (star.y > height)
          star.y = 0;
        else if (star.y < 0) star.y = height;
      });
    }
  }
}
