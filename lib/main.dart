import 'dart:async';
import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:bismuth/track_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bismuth/data_base.dart';
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:circle_indicator/circle_indicator.dart';

Group g1 = new Group(name: "gunit", order: 2);
Track t1 = new Track(name: "test2", group: g1, units: "hops");
List<TrackData> tds = [
  new TrackData(track: t1, time: new DateTime(2018, 1, 1), value: 10),
  new TrackData(track: t1, time: new DateTime(2018, 1, 15), value: 10)
];

Future<void> main() async {
  final dbConnection = await BismuthDbConnection.openConnection();

  //await dbConnection.initHello();
  //await dbConnection.initTestData();

  //debugPaintSizeEnabled = true;

  runApp(new BismuthApp(dbConnection));
}

typedef void Action(BuildContext context);

class Choice {
  const Choice({this.title, this.icon, this.action});

  final Action action;
  final String title;
  final IconData icon;

  call(BuildContext context) {
    if (action != null) {
      action(context);
    }
  }
}

MaterialPageRoute<void> createSaveTrackRoute() {
  return new MaterialPageRoute<void>(builder: (BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text("New Track")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
      ),
      body: new Column(children: <Widget>[
        new Expanded(
            child: TextField(
          decoration: InputDecoration(hintText: 'Name'),
        ))
      ]),
    );
  });
}

MaterialPageRoute<void> createSaveTrackDataRoute() {
  return new MaterialPageRoute<void>(builder: (BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text("Track Data Entry")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          // hide the software keyboard
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
      ),
      body: new Column(children: <Widget>[
        new Expanded(
            child: TextField(
          decoration: InputDecoration(hintText: 'Value'),
        ))
      ]),
    );
  });
}

List<Choice> choices = <Choice>[
  Choice(
      title: 'New Track',
      icon: Icons.add,
      action: (context) {
        Navigator.of(context).push(createSaveTrackRoute());
      }),
  const Choice(title: 'New Group', icon: Icons.add_shopping_cart),
  const Choice(title: 'Delete Track', icon: Icons.remove),
  const Choice(title: 'Delete Group', icon: Icons.remove_shopping_cart),
];

class BismuthApp extends StatelessWidget {
  final BismuthDbConnection dbConnection;

  BismuthApp(this.dbConnection);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bismuth',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new TracksPage(dbConnection),
    );
  }
}

class TracksPage extends StatefulWidget {
  final BismuthDbConnection dbConnection;

  TracksPage(this.dbConnection);

  @override
  State<StatefulWidget> createState() => TracksPageState(dbConnection);
}

class TracksPageState extends State<TracksPage> {
  final ValueNotifier<int> pageIndexNotifier = ValueNotifier<int>(0);
  final BismuthDbConnection dbConnection;
  final PageController controller;

  // mutable state
  final List<Track> tracks = new List<Track>();

  TracksPageState(this.dbConnection) {}

  @override
  void initState() {
    dbConnection.getTracks().then((newTracks) {
      setState(() {
        tracks.addAll(newTracks);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding:
            false, //this prevents this widget from resizing due to software keyboard (which would cause problems)
        appBar: new AppBar(
          title: Text('Bismuth'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(choices[0].icon),
              onPressed: () {
                choices[0](context);
              },
            ),
            // action button
            IconButton(
              icon: Icon(choices[1].icon),
              onPressed: () {
                choices[1](context);
              },
            ),
            // overflow menu
            PopupMenuButton<Choice>(
              onSelected: (choice) => choice(context),
              itemBuilder: (BuildContext context) {
                return choices.skip(2).map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(createSaveTrackDataRoute());
          },
        ),
        body: new Column(children: <Widget>[
          new Expanded(
              child: new PageView.builder(
            controller: controller,
            onPageChanged: (index) => pageIndexNotifier.value = index,
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              return new TrackPage(track: tracks[index], dbConnection: dbConnection);
            },
          )),
          //new CircleIndicator(controller, tracks.length, 3.0, Colors.white70, Colors.white)
        ]));
  }

  Widget _createPageIndicator(ValueNotifier<int> pageIndexNotifier, int length) {
    return PageViewIndicator(
      pageIndexNotifier: pageIndexNotifier,
      length: length,
      normalBuilder: (animationController) => Circle(
            size: 8.0,
            color: Colors.black87,
          ),
      highlightedBuilder: (animationController) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(
              size: 12.0,
              color: Colors.black45,
            ),
          ),
    );
  }
}
