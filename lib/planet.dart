import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'package:space_spin/sprite.dart';

class Planet extends Sprite {
  AnimationController controller;
  Animation animationX;
  Animation animationY;

  ui.Image rings;
  Rect ringSrc;
  double ringWidth;
  double ringHeight;

  Planet(double x, double y, double width, double height, ui.Image image,
      double screenWidth, double screenHeight, this.controller,
      {this.rings})
      : super(x, y, width, height, image, screenWidth, screenHeight) {
    Random random = new Random.secure();

    startX = x;
    startY = y;

    this.x = -20.0;

    rotationSpeed = random.nextDouble() * 0.2 + 0.15;

    if (rings != null) {
      ringSrc = new Rect.fromLTWH(
          0.0, 0.0, rings.width.toDouble(), rings.height.toDouble());
      ringWidth = (rings.width / image.width) * width;
      ringHeight = (rings.height / image.height) * height;
    }

    reset(0);
  }

  Planet.random(double width, double height, ui.Image image, double screenWidth,
      double screenHeight, this.controller,
      {this.rings})
      : super(0.0, 0.0, width, height, image, screenWidth, screenHeight) {
    Random random = new Random.secure();

    x = random.nextDouble() * ((2 * screenWidth) / 3) + (screenWidth / 6);
    y = random.nextDouble() * ((2 * screenHeight) / 5) + height;

    startX = x;
    startY = y;

    rotationSpeed = random.nextDouble() * 0.2 + 0.15;

    if (rings != null) {
      ringSrc = new Rect.fromLTWH(
          0.0, 0.0, rings.width.toDouble(), rings.height.toDouble());
      ringWidth = (rings.width / image.width) * width;
      ringHeight = (rings.height / image.height) * height;
    }

    reset(0);
  }

  @override
  void update(double dt) {
    //update rotation
    rotation += dt * rotationSpeed;

    //update planet location
    x += vx * dt;
    y += vy * dt;

    //update bounding box
    box = new vm.Quad.points(
        new vm.Vector3(x, y, 0.0),
        new vm.Vector3(x + width, y, 0.0),
        new vm.Vector3(x + width, y + height, 0.0),
        new vm.Vector3(x, y + height, 0.0));

    //if planet hits left of screen
    if (x < 0) {
      x = 0.0;
      vx *= -1;
    }
    //if planet hits right of screen
    else if (x + width > screenWidth) {
      x = screenWidth - width;
      vx *= -1;
    }
    //if planet hits top of screen
    if (y < 0) {
      y = 0.0;
      vy *= -1;
    }
    //if planet hits bottom of screen
    else if (y + height > screenHeight) {
      y = screenHeight - height;
      vy *= -1;
    }
  }

  @override
  void paint(Canvas canvas) {
    if (rings != null) {
      Rect dst = new Rect.fromLTWH(
          -ringWidth / 2, -ringHeight / 2, ringWidth, ringHeight);

      canvas.save();
      canvas.translate(x + ringWidth / 2 - ringWidth * .22, y + ringHeight / 2);
      canvas.rotate(rotation * 2 * pi);
      canvas.drawImageRect(rings, ringSrc, dst, new Paint());
      canvas.restore();
    }
    super.paint(canvas);
  }

  VoidCallback animate() {
    x = animationX.value;
    y = animationY.value;
    return null;
  }

  void reset(int difficulty) {
    if (controller != null) {
      Animation curve =
          new CurvedAnimation(parent: controller, curve: Curves.decelerate);
      animationX = new Tween(begin: x, end: startX).animate(curve)
        ..addListener(animate);
      animationY = new Tween(begin: y, end: startY).animate(curve);
      animationX.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationX.removeListener(animate);
        }
      });
      controller.forward(from: 0.0);
    } else {
      x = startX;
      y = startY;
    }

    rotation = 0.0;

    box = new vm.Quad.points(
        new vm.Vector3(x, y, 0.0),
        new vm.Vector3(x + width, y, 0.0),
        new vm.Vector3(x + width, y + height, 0.0),
        new vm.Vector3(x, y + height, 0.0));

    int min = 30;
    int range = 50;
    int diffMult = 2;

    Random rand = new Random.secure();

    if (rand.nextInt(2) == 0) {
      vx = (rand.nextDouble() * (range + difficulty * diffMult)) + min;
    } else {
      vx = -((rand.nextDouble() * (range + difficulty * diffMult)) + min);
    }
    if (rand.nextInt(2) == 0) {
      vy = (rand.nextDouble() * (range + difficulty * diffMult)) + min;
    } else {
      vy = -((rand.nextDouble() * (range + difficulty * diffMult)) + min);
    }
  }
}
