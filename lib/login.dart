import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginWidget extends StatefulWidget {
  final Function callback;

  LoginWidget(this.callback);

  @override
  LoginWidgetState createState() => new LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  List<String> adjectives;
  List<String> nouns;
  String name;

  @override
  void initState() {
    loadAssets();
    super.initState();
  }

  loadAssets() async {
    String string =
        await rootBundle.loadString('assets/words/adjectives-short.txt');
    adjectives = string.split('\n');

    string = await rootBundle.loadString('assets/words/nouns.txt');
    nouns = string.split('\n');

    generateName();
  }

  generateName() async {
    Random random = new Random.secure();

    String adjective = adjectives[random.nextInt(adjectives.length)];
    adjective = adjective[0].toUpperCase() + adjective.substring(1);

    String noun = nouns[random.nextInt(nouns.length)];
    noun = noun[0].toUpperCase() + noun.substring(1);

    name = "$adjective$noun";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Flexible(
        child: new Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          // Welcome to Space Spin!
          new Container(
              alignment: Alignment.center,
              child: new Text('Welcome to\nSpace Spin!',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontFamily: 'RammettoOne'))),
          // Generate your username:
          new Container(
              padding: new EdgeInsets.only(top: 45.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      bottom: new BorderSide(width: 2.0, color: Colors.white))),
              child: new Text('Generate your username:',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontFamily: 'OpenSans'))),
          // name
          name != null
              ? new Container(
                  padding: new EdgeInsets.all(15.0),
                  child: new Column(children: <Widget>[
                    new Text(name,
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontFamily: 'OpenSans',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold)),
                    new IconButton(
                        icon: new Icon(Icons.refresh),
                        onPressed: generateName,
                        color: Colors.white),
                  ]))
              : new CircularProgressIndicator(),
          new Padding(padding: new EdgeInsets.only(bottom: 20.0)),
          // select name
          new RaisedButton(
              elevation: 10.0,
              padding: new EdgeInsets.all(15.0),
              color: Colors.green,
              child: new Text('Confirm:',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontFamily: 'RammettoOne')),
              onPressed: () => widget.callback(name)),
        ]));
  }
}
