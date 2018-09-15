import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_admob/firebase_admob.dart';

import 'package:space_spin/about.dart';
import 'package:space_spin/game.dart';
import 'package:space_spin/leaderboard.dart';
import 'package:space_spin/planet.dart';

class TitlePage extends StatefulWidget {
  final Map<String, ui.Image> images;

  TitlePage(this.images);

  @override
  TitlePageState createState() => new TitlePageState();
}

class TitlePageState extends State<TitlePage>
    with SingleTickerProviderStateMixin {
  List<Planet> planets;
  Map<String, ui.Image> images;

  bool loaded;
  bool paused;
  bool resumed;

  double screenWidth;
  double screenHeight;

  AnimationController controller;
  int lastTime;

  BannerAd bannerAd;
  bool shouldShowAd;

  @override
  void initState() {
    super.initState();

    planets = new List();
    images = widget.images;

    loaded = false;
    paused = false;
    resumed = false;

    controller = new AnimationController(
        duration: new Duration(seconds: 1), vsync: this);
    controller.addListener(() => update());
    controller.repeat();
    lastTime = new DateTime.now().millisecondsSinceEpoch;

    //set handler for when lifecycle changes
    SystemChannels.lifecycle.setMessageHandler((msg) => updateLifecycle(msg));

    FirebaseAdMob.instance.initialize(appId: "test");
    shouldShowAd = true;
  }

  @override
  void dispose() {
    print("dispose");
    controller.dispose();
    SystemChannels.lifecycle.setMessageHandler(null);
    bannerAd.dispose();
    shouldShowAd = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 0.0 && !loaded) {
            screenWidth = constraints.maxWidth;
            screenHeight = constraints.maxHeight;
            screenHeight -= AdSize.banner.height;
            loaded = true;

            init();
          }
          return new Material(
              color: Colors.black,
              child: new Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image:
                          new AssetImage("assets/images/title-background.png"),
                          fit: BoxFit.cover)),
                  child: new Container(
                      width: screenWidth,
                      height: screenHeight,
                      child: new Stack(children: <Widget>[
                        //draw planets
                        new CustomPaint(
                            painter: new TitlePainter(planets, controller)),
                        //draw text and buttons
                        new Column(children: <Widget>[
                          //add title and buttons to stack
                          new Padding(
                              padding: new EdgeInsets.only(bottom: 50.0)),
                          new Text("Space Spin",
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 44.0,
                                  fontFamily: 'RammettoOne')),
                          new Padding(
                              padding: new EdgeInsets.only(bottom: 40.0)),
                          new _TitleButton(
                              text: "Play",
                              color: new Color.fromARGB(200, 255, 255, 255),
                              onPress: playButtonPressed),
                          new _TitleButton(
                              text: "Leaderboard",
                              color: new Color.fromARGB(200, 255, 255, 255),
                              onPress: leaderboardButtonPressed),
                          new _TitleButton(
                              text: "About",
                              color: new Color.fromARGB(200, 255, 255, 255),
                              onPress: aboutButtonPressed)
                        ]),
                      ]))));
        });
  }

  void init() async {
    createBannerAd();
    initPlanets();
  }

  void initPlanets() {
    Random random = new Random.secure();

    //add five random planets
    for (int i = 0; i < 5; i++) {
      //add 5 planets to the list
      int num = random.nextInt(9);
      ui.Image image = images.values.toList()[num];
      bool isSaturn = num == 5;

      Planet p = new Planet.random(
          50.0, 50.0, image, screenWidth, screenHeight, null,
          rings: isSaturn ? images['Rings'] : null);
      planets.add(p);
    }
  }

  createBannerAd() async {
    bannerAd = new BannerAd(
      adUnitId: "test",
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if(event == MobileAdEvent.loaded && shouldShowAd) {
          bannerAd.show();
        }
      },
    );
    bannerAd.load();
  }

  void update() {
    int now = new DateTime.now().millisecondsSinceEpoch;
    double dt = (now - lastTime) / 1000;

    if (!resumed) {
      // don't update for the first tick after being resumed
      if (!paused) {
        planets.forEach((p) => p.update(dt));
      }
    } else {
      resumed = false;
    }

    lastTime = now;
  }

  void playButtonPressed() {
    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new GamePage(images)));
  }

  void leaderboardButtonPressed() {
    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new LeaderboardPage()));
  }

  void aboutButtonPressed() {
    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new AboutPage(images)));
  }

  updateLifecycle(String msg) {
    print(msg);
    if (msg == "AppLifecycleState.paused") {
      paused = true;
    } else if (msg == "AppLifecycleState.resumed") {
      paused = false;
      resumed = true;
    }
  }
}

class _TitleButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPress;

  _TitleButton({this.text, this.color, this.onPress});

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: new EdgeInsets.all(15.0),
        child: new FlatButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.all(new Radius.circular(40.0))),
            color: color,
            onPressed: onPress,
            child: new Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(text,
                      style: new TextStyle(
                          fontSize: 26.0,
                          fontFamily: 'RammettoOne',
                          color: Colors.black)),
                  new Padding(
                      padding: new EdgeInsets.only(top: 45.0, bottom: 45.0))
                ])));
  }
}

class TitlePainter extends CustomPainter {
  List<Planet> planets;

  TitlePainter(this.planets, AnimationController controller)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    for (Planet p in planets) {
      p.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
