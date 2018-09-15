import 'package:flutter/material.dart';
import 'package:space_spin/game.dart';

class PauseWidget extends StatelessWidget {
  final GamePageState game;

  PauseWidget(this.game);

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
            height: 200.0,
            padding: new EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
            color: new Color.fromARGB(175, 255, 255, 255),
            child: new Column(children: <Widget>[
              new Text("Paused",
                  style: new TextStyle(
                      fontSize: 36.0,
                      color: Colors.black,
                      fontFamily: 'RammettoOne')),
              new IconButton(
                icon: new Icon(Icons.play_circle_outline),
                color: Colors.black,
                onPressed: game.hidePauseMenu,
                iconSize: 60.0,
              ),
            ])));
  }
}
