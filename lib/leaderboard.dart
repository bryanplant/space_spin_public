import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:path_provider/path_provider.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  LeaderboardPageState createState() => new LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  DatabaseReference reference;
  FirebaseAnimatedList list;

  int totalPlayers;
  int userScore;
  int userIndex;
  int prevScore;
  int prevIndex;

  @override
  initState() {
    super.initState();

    reference = FirebaseDatabase.instance.reference();

    totalPlayers = 0;
    userScore = 0;
    userIndex = 0;

    buildList();
    getRank();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return new Material(
          color: Colors.black,
          child: new Container(
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage(
                          "assets/images/results-background.png"),
                      fit: BoxFit.cover)),
              child: new Column(children: <Widget>[
                new Container(
                    color: new Color.fromARGB(155, 0, 0, 0),
                    width: constraints.maxWidth,
                    padding: new EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: new Stack(children: <Widget>[
                      new BackButton(
                        color: Colors.white,
                      ),
                      new Center(
                          child: new Text(
                              "High Score: $userScore\nYou are #$userIndex out of $totalPlayers!",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'RammettoOne')))
                    ])),
                new Container(
                    width: 300.0,
                    height: constraints.maxHeight - 164.0,
                    child: list == null
                        ? new Center(
                            child: new Container(
                                width: 50.0,
                                height: 50.0,
                                child: new CircularProgressIndicator()))
                        : list),
              ])));
    });
  }

  buildList() async {
    File file = await _getLocalFile('uuid.txt');
    String uuid = await file.readAsString();

    list = new FirebaseAnimatedList(
      query: reference.child('users').limitToFirst(50),
      sort: (a, b) => b.value['score'].compareTo(a.value['score']),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation animation, int index) {
        bool isUser = snapshot.key == uuid;

        String name = snapshot.value['name'];
        int score = snapshot.value['score'];
        index += 1;

        if (score == prevScore) index = prevIndex;

        prevIndex = index;
        prevScore = score;

        return new ScoreCard(name, score.toString(), index, isUser);
      },
    );
  }

  getRank() async {
    File file = await _getLocalFile('uuid.txt');
    String uuid = await file.readAsString();

    Map<String, dynamic> map;

    await reference
        .child('users')
        .orderByChild('score')
        .once()
        .then((snapshot) {
      map = new Map<String, dynamic>.from(snapshot.value);
    });

    setState(() {
      userScore = map[uuid]['score'];
      userIndex =
          map.values.toList().where((a) => (a['score'] > userScore)).length + 1;
      totalPlayers = map.length;
    });
  }

  Future<File> _getLocalFile(String name) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$name');
  }
}

class ScoreCard extends StatefulWidget {
  final String name;
  final String score;
  final int index;
  final bool isUser;

  ScoreCard(this.name, this.score, this.index, this.isUser);

  ScoreCardState createState() => new ScoreCardState();
}

class ScoreCardState extends State<ScoreCard> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: new EdgeInsets.only(bottom: 5.0),
        child: new Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                border: new Border.all(
                    color: widget.isUser ? Colors.green : Colors.white,
                    width: 2.0),
                color: Colors.black),
            child: new Container(
                padding: new EdgeInsets.only(left: 30.0),
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  new Text("${widget.index}. ${widget.name}",
                      style: new TextStyle(
                        fontSize: 22.0,
                        color: widget.isUser ? Colors.green : Colors.white,
                      )),
                  new Text("Score: ${widget.score}",
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                      )),
                ]))));
  }
}
