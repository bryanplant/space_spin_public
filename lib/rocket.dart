import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math.dart' as vm;

import 'package:space_spin/planet.dart';
import 'package:space_spin/sprite.dart';

class Rocket extends Sprite {
  double impulse; //how much to increase velocity by
  int turning; //0 if not turning, 1 if c-clockwise, 2 if clockwise

  Rocket(double width, double height, ui.Image image, double screenWidth,
      double screenHeight)
      : super(0.0, 0.0, width, height, image, screenWidth, screenHeight) {
    x = screenWidth / 2 - width / 2;
    y = 4 * screenHeight / 5;

    startX = x;
    startY = y;

    rotationSpeed = 0.75;
    impulse = 2.0;

    reset();
  }

  @override
  void update(double dt) {
    //turn rocket left
    if (turning == 1) {
      rotation -= rotationSpeed * dt;
      if (rotation < 0) rotation = 1.0;
    }
    //turn rocket right
    else if (turning == 2) {
      rotation += rotationSpeed * dt;
      if (rotation > 1) rotation = 0.0;
    }

    //increase velocity based on rotation
    vx += impulse * sin(rotation * 2 * pi);
    vy += impulse * -cos(rotation * 2 * pi);

    //change position
    x += vx * dt;
    y += vy * dt;

    //update bounding box
    box = new vm.Obb3.centerExtentsAxes(
        new vm.Vector3(x + width / 2, y + height / 2, 0.0),
        new vm.Vector3(width / 3, height / 2, 0.0),
        new vm.Vector3(1.0, 0.0, 0.0),
        new vm.Vector3(0.0, 1.0, 0.0),
        new vm.Vector3(0.0, 0.0, 1.0));
    box.rotate(new vm.Matrix3.rotationZ(rotation * 2 * pi));
  }

  bool exitHit(vm.Quad exit) => box.intersectsWithQuad(exit);

  bool planetHit(List<Planet> planets) {
    for (Planet p in planets) {
      if (box.intersectsWithQuad(p.box)) return true;
    }
    return false;
  }

  bool wallHit() {
    vm.Vector3 corner = new vm.Vector3.zero();
    for (int i = 0; i <= 6; i += 2) {
      box.copyCorner(i, corner);
      if (corner.x < 0 ||
          corner.x > screenWidth ||
          corner.y < 0 ||
          corner.y > screenHeight) {
        return true;
      }
    }
    return false;
  }

  void reset() {
    x = startX;
    y = startY;
    vx = 0.0;
    vy = 0.0;
    rotation = 0.0;
    turning = 0;

    box = new vm.Obb3.centerExtentsAxes(
        new vm.Vector3(x + width / 3, y + height / 2, 0.0),
        new vm.Vector3(width / 3, height / 2, 0.0),
        new vm.Vector3(1.0, 0.0, 0.0),
        new vm.Vector3(0.0, 1.0, 0.0),
        new vm.Vector3(0.0, 0.0, 1.0));
  }
}
