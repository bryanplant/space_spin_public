import 'dart:math';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

class Exit {
  double width;
  double screenWidth;
  double borderWidth;
  vm.Quad box;
  vm.Quad drawBox;

  Exit(this.screenWidth, this.borderWidth) {
    width = 80.0;
    box = new vm.Quad();
    drawBox = new vm.Quad();
  }

  void move() {
    Random random = new Random.secure();
    double randLim = width + borderWidth * 2;
    double start = random.nextDouble() * (screenWidth - randLim) + randLim / 2;
    start -= width / 2;

    int wall = random.nextInt(3);

    if (wall == 0) {
      box = new vm.Quad.points(
          new vm.Vector3(0.0, start, 0.0),
          new vm.Vector3(0.0, start + width, 0.0),
          new vm.Vector3(borderWidth * 2, start + width, 0.0),
          new vm.Vector3(borderWidth * 2, start, 0.0));

      drawBox = new vm.Quad.points(
          new vm.Vector3(0.0, start, 0.0),
          new vm.Vector3(0.0, start + width, 0.0),
          new vm.Vector3(borderWidth, start + width, 0.0),
          new vm.Vector3(borderWidth, start, 0.0));
    } else if (wall == 1) {
      box = new vm.Quad.points(
          new vm.Vector3(start, 0.0, 0.0),
          new vm.Vector3(start + width, 0.0, 0.0),
          new vm.Vector3(start + width, borderWidth * 2, 0.0),
          new vm.Vector3(start, borderWidth * 2, 0.0));

      drawBox = new vm.Quad.points(
          new vm.Vector3(start, 0.0, 0.0),
          new vm.Vector3(start + width, 0.0, 0.0),
          new vm.Vector3(start + width, borderWidth, 0.0),
          new vm.Vector3(start, borderWidth, 0.0));
    } else {
      box = new vm.Quad.points(
          new vm.Vector3(screenWidth - borderWidth * 2, start, 0.0),
          new vm.Vector3(screenWidth - borderWidth * 2, start + width, 0.0),
          new vm.Vector3(screenWidth, start + width, 0.0),
          new vm.Vector3(screenWidth, start, 0.0));

      drawBox = new vm.Quad.points(
          new vm.Vector3(screenWidth - borderWidth, start, 0.0),
          new vm.Vector3(screenWidth - borderWidth, start + width, 0.0),
          new vm.Vector3(screenWidth, start + width, 0.0),
          new vm.Vector3(screenWidth, start, 0.0));
    }
  }

  void paint(Canvas canvas) {
    canvas.drawRect(
        new Rect.fromLTRB(drawBox.point0.x, drawBox.point0.y, drawBox.point2.x,
            drawBox.point2.y),
        new Paint()..color = Colors.black);
  }
}

class ExitPainter extends CustomPainter {
  Exit exit;

  ExitPainter(this.exit, AnimationController controller)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    exit.paint(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
