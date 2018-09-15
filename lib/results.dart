import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';

import 'package:space_spin/game.dart';
import 'package:space_spin/title.dart';

class ResultsPage extends StatefulWidget {
  final int score;
  final Map<String, ui.Image> images;
  final InterstitialAd interstitialAd;

  ResultsPage(this.score, this.images, this.interstitialAd);

  @override
  ResultsPageState createState() => new ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  DatabaseReference reference;

  int highScore = 0;

  @override
  initState() {
    super.initState();

    reference = FirebaseDatabase.instance.reference();

    widget.interstitialAd?.show();

    updateScore();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.lightBlue,
        child: new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image:
                        new AssetImage("assets/images/results-background.png"),
                    fit: BoxFit.cover)),
            padding: new EdgeInsets.all(10.0),
            child: new Column(children: <Widget>[
              new Flexible(
                  child: new Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    new ResultsCard(text: "Score: ${widget.score}"),
                    new ResultsCard(text: "High Score: $highScore"),
                    new Padding(padding: new EdgeInsets.only(bottom: 50.0)),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new FlatButton(
                              child: new Column(children: <Widget>[
                                new Icon(Icons.replay,
                                    color: Colors.white, size: 60.0),
                                new Text("Retry",
                                    style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontFamily: 'RammettoOne'))
                              ]),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    new PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            new GamePage(widget.images)));
                              }),
                          new FlatButton(
                              child: new Column(children: <Widget>[
                                new Icon(Icons.home,
                                    color: Colors.white, size: 60.0),
                                new Text("Go Home",
                                    style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontFamily: 'RammettoOne'))
                              ]),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    new PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            new TitlePage(widget.images)));
                              }),
                        ]),
                  ]))
            ])));
  }

  Future updateScore() async {
    File file = await _getLocalFile("uuid.txt");
    String myUuid = await file.readAsString();
    print("Updating score for $myUuid");

    file = await _getLocalFile("highscore.txt");
    String highScoreString = await file.readAsString();
    highScore = int.parse(highScoreString);

    setState(() {});

    //update local high score
    if (widget.score > highScore) {
      highScore = widget.score;
      await file.writeAsString(widget.score.toString());
      reference.child('users/$myUuid/score').keepSynced(true);
      await reference.child('users/$myUuid/score').set(highScore);
    }
  }

  Future<File> _getLocalFile(String name) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$name');
  }
}

class ResultsCard extends StatefulWidget {
  final String text;

  ResultsCard({this.text});

  _ResultsCardState createState() => new _ResultsCardState();
}

class _ResultsCardState extends State<ResultsCard> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: new Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
                color: Colors.grey[800]),
            child: new Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(widget.text,
                      style: new TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Open Sans')),
                  new Padding(
                      padding: new EdgeInsets.only(top: 45.0, bottom: 45.0))
                ])));
  }
}
