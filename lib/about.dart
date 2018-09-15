import 'dart:ui' as ui;

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:space_spin/planet.dart';

class AboutPage extends StatelessWidget {
  final Map<String, ui.Image> images;

  AboutPage(this.images);

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return new Material(
          color: Colors.grey[800],
          child: new Container(
              height: constraints.maxHeight - AdSize.banner.height,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //planets
                  new Container(
                      width: constraints.maxWidth,
                      padding: new EdgeInsets.only(top: 20.0, bottom: 40.0),
                      child:
                          new CustomPaint(painter: new AboutPainter(images))),
                  // About
                  new Container(
                      alignment: Alignment.center,
                      child: new Text('About',
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontFamily: 'RammettoOne'))),
                  // Description
                  new Container(
                      padding: new EdgeInsets.all(25.0),
                      alignment: Alignment.center,
                      child: new RichText(
                        textAlign: TextAlign.center,
                        text: new TextSpan(
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontFamily: 'OpenSans'),
                          text:
                              'Space Spin is a game in which you are an astronaut, lost in the solar system, with your engine throttle stuck in the ',
                          children: <TextSpan>[
                            new TextSpan(
                                text: 'ON',
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            new TextSpan(
                                text:
                                    ' position!\n\nAvoid the planets and moons, get to the exit, rack up points and reach the top of the leaderboards.\n Good luck!'),
                          ],
                        ),
                      )),
                  // home button
                  new FlatButton(
                      child: new Column(children: <Widget>[
                        new Icon(Icons.arrow_back,
                            color: Colors.white, size: 40.0),
                        new Text("Go Home",
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontFamily: 'RammettoOne'))
                      ]),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  new Padding(padding: new EdgeInsets.only(bottom: 20.0)),
                  //planets
                  new Container(
                      width: constraints.maxWidth,
                      height: 40.0,
                      child: new CustomPaint(
                          painter: new AboutPainter(images, reverse: true))),
                  //acknowledgment
                  new Container(
                      alignment: Alignment.center,
                      child: new Text(
                          'Thanks to Freepik and Vecteezy for the planet art!',
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontFamily: 'OpenSans'))),
                ],
              )));
    });
  }
}

class AboutPainter extends CustomPainter {
  Map<String, ui.Image> images;
  bool reverse;

  AboutPainter(this.images, {this.reverse = false});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    double margin = 2.0;
    double pSize = (size.width - margin * 11) / 10;

    for (int i = 0; i < 10; i++) {
      int index = reverse ? 9 - i : i;
      ui.Image image = images.values.toList()[index];
      bool isSaturn = index == 5;

      Planet p = new Planet(i * pSize + i * margin + margin, 0.0, pSize, pSize,
          image, size.width, size.height, null,
          rings: isSaturn ? images['Rings'] : null);
      p.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
