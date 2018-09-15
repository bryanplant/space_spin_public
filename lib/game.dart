import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:space_spin/exit.dart';
import 'package:space_spin/info_display.dart';

import 'package:space_spin/controls.dart';
import 'package:space_spin/level_generator.dart';
import 'package:space_spin/pause.dart';
import 'package:space_spin/planet.dart';
import 'package:space_spin/results.dart';
import 'package:space_spin/rocket.dart';

class GamePage extends StatefulWidget {
  final Map<String, ui.Image> images;

  GamePage(this.images);

  @override
  GamePageState createState() => new GamePageState();
}

class GamePageState extends State<GamePage> with TickerProviderStateMixin {
  Rocket rocket;
  List<Planet> planets;
  ControlsWidget controls;
  Exit exit;
  LevelGenerator levelGenerator;

  Map<String, ui.Image> images;

  int score;
  int numMoons;

  double screenWidth;
  double screenHeight;
  double borderWidth;

  Timer infoTimer;
  InfoDisplay info;

  bool loaded;
  bool showInfo;
  bool showingPauseMenu;
  bool paused;
  bool resumed;
  bool lost;

  AnimationController controller;
  AnimationController resetController;
  int lastTime;

  InterstitialAd interstitialAd;

  @override
  initState() {
    super.initState();
    planets = new List();
    levelGenerator = new LevelGenerator(this);

    images = widget.images;

    borderWidth = 5.0;
    screenWidth = 0.0;
    screenHeight = 0.0;

    score = 0;
    numMoons = 0;

    info = new InfoDisplay("Level 1", "Get to the Exit!");

    loaded = false;
    showInfo = false;
    showingPauseMenu = false;
    paused = false;
    resumed = false;
    lost = false;

    controller = new AnimationController(
        duration: new Duration(seconds: 1), vsync: this);
    controller.addListener(() => update());
    controller.repeat();

    resetController = new AnimationController(
        duration: new Duration(milliseconds: 800), vsync: this);

    lastTime = new DateTime.now().millisecondsSinceEpoch;

    SystemChannels.lifecycle.setMessageHandler((msg) => updateLifecycle(msg));

    FirebaseAdMob.instance.initialize(appId: "test");
    loadAd();
  }

  @override
  void dispose() {
    infoTimer.cancel();
    controller.dispose();
    interstitialAd?.dispose();
    SystemChannels.lifecycle.setMessageHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 0.0 && !loaded) {
        screenWidth = constraints.maxWidth;
        screenHeight = constraints.maxHeight;
        loaded = true;
        init();
      }

      return new WillPopScope(
          onWillPop: () async => false,
          child: new Material(
              child: new Container(
                  color: Colors.black,
                  child: new Stack(children: <Widget>[
                    //game border and image
                    new Container(
                        width: screenWidth,
                        height: screenHeight,
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                                image: new AssetImage(
                                    "assets/images/game-background.png"),
                                fit: BoxFit.cover),
                            border: new Border.all(
                                width: borderWidth, color: Colors.white)),
                        child: new Stack(children: <Widget>[
                          //game painter
                          !lost
                              ? new CustomPaint(
                                  painter: new GamePainter(
                                      rocket, planets, controller))
                              : new Container(),
                          //controls
                          controls != null ? controls : new Container(),
                        ])),
                    //exit
                    new CustomPaint(painter: new ExitPainter(exit, controller)),
                    //score
                    new Positioned(
                        left: 15.0,
                        top: 15.0,
                        child: new Text(score.toString(),
                            style: new TextStyle(
                                fontSize: 28.0,
                                color: Colors.white,
                                fontFamily: 'RammettoOne'))),
                    //pause button
                    new Positioned(
                        right: 15.0,
                        top: 15.0,
                        child: new IconButton(
                            icon: new Icon(Icons.pause, size: 35.0),
                            color: Colors.white,
                            onPressed: showPauseMenu)),
                    //level info
                    showInfo ? info : new Container(),
                    //pause menu
                    showingPauseMenu ? new PauseWidget(this) : new Container(),
                  ]))));
    });
  }

  //initialize objects once screen size is identified
  void init() {
    exit = new Exit(screenWidth, borderWidth);
    exit.move(); //set exit location

    rocket = new Rocket(21.5, 40.0, images['rocket'],
        screenWidth - borderWidth * 2, screenHeight - borderWidth * 2);

    controls = new ControlsWidget(rocket);

    //show starting info
    showInfo = true;
    paused = true;
    infoTimer = new Timer(
        new Duration(milliseconds: 1350),
        () => setState(() {
              if (!showingPauseMenu) {
                paused = false;
              }
              showInfo = false;
              resumed = true;
            }));
  }

  void update() {
    int now = new DateTime.now().millisecondsSinceEpoch;
    double dt = (now - lastTime) / 1000;

    if (!resumed) {
      // don't update for the first tick after being resumed
      if (!paused && !lost) {
        rocket.update(dt);
        planets.forEach((p) => p.update(dt));

        if (rocket.exitHit(exit.box))
          newLevel();
        else if (rocket.wallHit() || rocket.planetHit(planets)) {
          lose();
          lost = true;
        }
      }
    } else {
      resumed = false;
    }

    lastTime = now;
  }

  void newLevel() {
    setState(() {
      levelGenerator.newLevel();

      //pause and show level info
      paused = true;
      showInfo = true;
      infoTimer = new Timer(new Duration(milliseconds: 900), () {
        setState(() {
          if (!showingPauseMenu) {
            paused = false;
          }
          resumed = true;
          infoTimer = new Timer(new Duration(milliseconds: 1000), () {
            setState(() {
              showInfo = false;
            });
          });
        });
      });
    });
  }

  Future<String> updateLifecycle(String msg) {
    print(msg);
    if (msg == "AppLifecycleState.paused") {
      showPauseMenu();
    }

    return null;
  }

  void lose() {
    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            new ResultsPage(score, images, interstitialAd)));
  }

  void showPauseMenu() {
    setState(() {
      showingPauseMenu = true;
      paused = true;
    });
  }

  void hidePauseMenu() {
    setState(() {
      showingPauseMenu = false;
      paused = false;
      resumed = true;
    });
  }

  loadAd() async {
    File file = await _getLocalFile('adcounter.txt');
    String countString = await file.readAsString();
    int count = int.parse(countString);
    if (count >= 4) {
      interstitialAd = new InterstitialAd(
        adUnitId: "test",
        listener: (MobileAdEvent event) {
          print(event);
        },
      );
      interstitialAd.load();
      count = 0;
    } else {
      count++;
    }
    file.writeAsString(count.toString());
  }

  Future<File> _getLocalFile(String name) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$name');
  }
}

class GamePainter extends CustomPainter {
  Rocket rocket;
  List<Planet> planets;

  GamePainter(this.rocket, this.planets, AnimationController controller)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    rocket.paint(canvas);
    planets.forEach((p) => p.paint(canvas));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
