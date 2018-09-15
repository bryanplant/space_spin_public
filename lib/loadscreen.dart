import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:space_spin/about.dart';
import 'package:space_spin/login.dart';
import 'package:uuid/uuid.dart';

import 'package:space_spin/title.dart';

class LoadScreen extends StatefulWidget {
  @override
  LoadScreenState createState() => new LoadScreenState();
}

class LoadScreenState extends State<LoadScreen> {
  var uuid;
  String myUuid;
  DatabaseReference reference;

  bool showLogin;
  bool loaded;
  bool firstLoad;

  @override
  void initState() {
    uuid = new Uuid();

    showLogin = false;
    loaded = false;
    firstLoad = false;

    initDatabase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.black,
        child: new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("assets/images/title-background.png"),
                    fit: BoxFit.cover)),
            child: new Column(children: <Widget>[
              //load background images for the first time
              new Image.asset('assets/images/title-background.png',
                  width: 0.0, height: 0.0),
              new Image.asset('assets/images/game-background.png',
                  width: 0.0, height: 0.0),
              new Image.asset('assets/images/results-background.png',
                  width: 0.0, height: 0.0),
              showLogin ? new LoginWidget(setUserName) : new Container(),
            ])));
  }

  setUserName(String name) async {
    await (await _getLocalFile("name.txt"))
        .writeAsString(name); //create file for high score

    createDatabaseUser(0, name);
  }

  Future initDatabase() async {
    await FirebaseDatabase.instance.setPersistenceEnabled(true);
    reference = FirebaseDatabase.instance.reference();

    //setup UUID file and database reference on first open
    try {
      //get local uuid
      File file = await _getLocalFile("uuid.txt");
      myUuid = await file.readAsString();
      print(myUuid);

      loadImages();
    } on FileSystemException {
      //generate new uuid
      myUuid = uuid.v4();

      firstLoad = true;

      setState(() {
        showLogin = true;
      });
    }
  }

  createDatabaseUser(int highScore, String name) async {
    //create local uuid file
    await (await _getLocalFile("uuid.txt")).writeAsString(myUuid);
    //create local high score file
    await (await _getLocalFile("highscore.txt")).writeAsString("0");
    //create file to keep track of ad frequency
    await (await _getLocalFile("adcounter.txt")).writeAsString("0");

    //create a database user with given high score
    reference
        .child('users')
        .child(myUuid)
        .set({'score': highScore, 'name': name});

    loadImages();
  }

  Future<File> _getLocalFile(String name) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$name');
  }

  loadImages() async {
    Map<String, ui.Image> images = new Map();
    images['Mercury'] = await loadImage('assets/images/mercury.png');
    images['Venus'] = await loadImage('assets/images/venus.png');
    images['Earth'] = await loadImage('assets/images/earth.png');
    images['Mars'] = await loadImage('assets/images/mars.png');
    images['Jupiter'] = await loadImage('assets/images/jupiter.png');
    images['Saturn'] = await loadImage('assets/images/saturn.png');
    images['Uranus'] = await loadImage('assets/images/uranus.png');
    images['Neptune'] = await loadImage('assets/images/neptune.png');
    images['Pluto'] = await loadImage('assets/images/pluto.png');
    images['Moon'] = await loadImage('assets/images/moon.png');

    images['rocket'] = await loadImage('assets/images/rocket-blast.png');
    images['Rings'] = await loadImage('assets/images/rings.png');

    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new TitlePage(images)));

    if (firstLoad) {
      Navigator.of(context).push(new PageRouteBuilder(
          pageBuilder: (_, __, ___) => new AboutPage(images)));
    }
  }

  Future<ui.Image> loadImage(String url) async {
    ImageStream stream = new AssetImage(url, bundle: rootBundle)
        .resolve(ImageConfiguration.empty);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    void listener(ImageInfo frame, bool synchronousCall) {
      final ui.Image image = frame.image;
      completer.complete(image);
      stream.removeListener(listener);
    }

    stream.addListener(listener);
    return completer.future;
  }
}
