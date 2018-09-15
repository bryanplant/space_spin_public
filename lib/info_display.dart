import 'package:flutter/material.dart';

class InfoDisplay extends StatelessWidget {
  final String info1;
  final String info2;

  InfoDisplay(this.info1, this.info2);

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          new Text(info1,
              style: new TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontFamily: 'RammettoOne')),
          new Text(info2,
              style: new TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontFamily: 'RammettoOne')),
        ]));
  }
}
