import 'dart:convert';

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FlareExplorer(),
    );
  }
}

class FlareExplorer extends StatelessWidget {
  const FlareExplorer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Object>(
        future: DefaultAssetBundle.of(context).loadString('AssetManifest.json'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Waiting on data...');
          }
          return ListView(
            children: [
              ...Map<String, dynamic>.from(json.decode(snapshot.data))
                  .keys
                  .where((key) => key.contains('flares/'))
                  .map((e) => FlatButton(
                        child: Text(e),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FlarePlayer(flarePath: e),
                          ));
                        },
                      ))
            ],
          );
        },
      ),
    );
  }
}

class FlarePlayer extends StatefulWidget {
  final String flarePath;

  const FlarePlayer({Key key, @required this.flarePath}) : super(key: key);

  @override
  _FlarePlayerState createState() => new _FlarePlayerState();
}

class _FlarePlayerState extends State<FlarePlayer> {
  final FlareControls controls = FlareControls();
  String _animation = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlutterActor>(
        future: rootBundle
            .load(widget.flarePath)
            .then((value) => FlutterActor.loadFromByteData(value)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container();
          }
          return Stack(
            children: [
              if (_animation != null)
                FlareActor(
                  widget.flarePath,
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: _animation,
                  isPaused: false,
                  controller: controls,
                ),
              Row(children: [
                ...snapshot.data.artboard.actor.artboard.animations.map(
                  (e) => FlatButton(
                      onPressed: () {
                        setState(() {
                          _animation = e.name;
                        });
                      },
                      child: Text(e.name)),
                )
              ]),
            ],
          );
        });
  }
}
