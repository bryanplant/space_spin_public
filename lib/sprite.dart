import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class Sprite {
  double x;
  double y;
  double startX;
  double startY;
  var box;
  double vx;
  double vy;
  double width;
  double height;
  double rotation;
  double rotationSpeed;
  ui.Image image;
  Rect src;

  double screenWidth;
  double screenHeight;

  Sprite(this.x, this.y, this.width, this.height, this.image, this.screenWidth,
      this.screenHeight) {
    src = new Rect.fromLTWH(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
  }

  void update(double dt);

  void paint(Canvas canvas) {
    Rect dst = new Rect.fromLTWH(-width / 2, -height / 2, width, height);

    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(rotation * 2 * pi);
    canvas.drawImageRect(image, src, dst, new Paint());
    canvas.restore();
  }
}
