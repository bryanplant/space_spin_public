import 'dart:math';
import 'dart:ui' as ui;

import 'package:space_spin/game.dart';
import 'package:space_spin/info_display.dart';
import 'package:space_spin/planet.dart';

class LevelGenerator {
  int level;
  int nextPlanet;
  int minMoons;
  int maxMoons;
  double planetSize;
  double moonSize;

  GamePageState game;

  LevelGenerator(this.game) {
    level = 1;
    nextPlanet = 0;
    minMoons = 0;
    maxMoons = 2;
    planetSize = 40.0;
  }

  void newLevel() {
    game.score += game.planets.length == 0 ? 1 : game.planets.length;

    game.info = new InfoDisplay("Level $level", "");

    level++;

    game.info = new InfoDisplay("Level $level", "");

    //reset moons, add new planet
    if (level == 2 || game.numMoons >= maxMoons) {
      if (level != 2) {
        minMoons++;
        maxMoons++;
      }

      game.planets = new List();

      bool isSaturn = nextPlanet == 5;
      ui.Image image = getNextPlanet();

      Planet p = new Planet(
          game.screenWidth / 2 - planetSize / 2,
          game.screenHeight / 4,
          planetSize,
          planetSize,
          image,
          game.screenWidth - game.borderWidth * 2,
          game.screenHeight - game.borderWidth * 2,
          game.resetController,
          rings: isSaturn ? game.images['Rings'] : null);
      //add planet
      game.planets.add(p);

      game.numMoons = 0;

      //add moons
      for (int i = 0; i < minMoons; i++) {
        addMoon();
      }

      nextPlanet++;
      if (nextPlanet > 8) {
        nextPlanet = 0;
      }
    }
    //add a moon
    else if (level != 1) {
      addMoon();
      game.info = new InfoDisplay(game.info.info1, "New Moon");
    }

    game.rocket.reset();
    game.planets.forEach((p) => p.reset(level));

    game.exit.move();
  }

  void addMoon() {
    Random random = new Random.secure();
    moonSize = random.nextDouble() * 13 + 12;

    double distance = 100.0;
    double angle = ((2 * pi) / maxMoons) * game.numMoons;
    double x = (cos(angle) * distance) +
        game.planets[0].startX +
        planetSize / 2 -
        moonSize / 2;
    double y = (sin(angle) * distance) +
        game.planets[0].startY +
        planetSize / 2 -
        moonSize / 2;

    Planet p = new Planet(
        x,
        y,
        moonSize,
        moonSize,
        game.images['Moon'],
        game.screenWidth - game.borderWidth * 2,
        game.screenHeight - game.borderWidth * 2,
        game.resetController);
    game.planets.add(p);

    game.numMoons++;
  }

  ui.Image getNextPlanet() {
    String info2 = "New Planet: ";

    info2 += game.images.keys.toList()[nextPlanet];

    game.info = new InfoDisplay(game.info.info1, info2);

    return game.images.values.toList()[nextPlanet];
  }
}
