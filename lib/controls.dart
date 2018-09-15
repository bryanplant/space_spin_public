import 'package:flutter/material.dart';

import 'package:space_spin/rocket.dart';

class ControlsWidget extends StatefulWidget {
  final Rocket rocket;

  ControlsWidget(this.rocket);

  @override
  ControlsWidgetState createState() => new ControlsWidgetState();
}

class ControlsWidgetState extends State<ControlsWidget> {
  Rocket rocket;

  @override
  initState() {
    super.initState();
    rocket = widget.rocket;
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return new Stack(children: <Widget>[
        //show left button
        new Positioned(
            left: 0.0,
            bottom: 0.0,
            child: new Listener(
                onPointerDown: (_) => rocket.turning = 1, //turn left
                onPointerUp: (_) {
                  if (rocket.turning == 1) {
                    rocket.turning = 0;
                  }
                },
                child: new Container(
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        color: new Color.fromARGB(170, 33, 150, 243),
                        border:
                            new Border.all(color: Colors.white, width: 2.5)),
                    width: rocket.screenWidth / 2,
                    height: 75.0,
                    child: new Icon(Icons.rotate_left,
                        size: 40.0, color: Colors.white)))),
        //show right button
        new Positioned(
            right: 0.0,
            bottom: 0.0,
            child: new Listener(
                onPointerDown: (_) => rocket.turning = 2, //turn right
                onPointerUp: (_) {
                  if (rocket.turning == 2) {
                    rocket.turning = 0;
                  }
                },
                child: new Container(
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        color: new Color.fromARGB(170, 33, 150, 243),
                        border:
                            new Border.all(color: Colors.white, width: 2.5)),
                    width: rocket.screenWidth / 2,
                    height: 75.0,
                    child: new Icon(Icons.rotate_right,
                        size: 40.0, color: Colors.white)))),
      ]);
    });
  }
}
