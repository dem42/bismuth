import 'dart:async';
import 'dart:convert';
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

class Choice {
  const Choice({this.title, this.icon, this.actionType = ChoiceActionType.OTHER});

  final String title;
  final IconData icon;
  final ChoiceActionType actionType;
}

typedef void OnTrackSaveHandler(Track track);

class NewTrackPage extends StatelessWidget {
  final OnTrackSaveHandler trackHandler;
  Track newTrack = new Track(group: Group(name: "default"), units: "units");

  NewTrackPage({Key key, this.trackHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text("New Track")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          trackHandler(newTrack);
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
      ),
      body: new Column(children: <Widget>[
        new Expanded(
            child: TextField(
          decoration: InputDecoration(hintText: 'Name'),
          onChanged: (newName) => newTrack.name = newName,
        ))
      ]),
    );
  }
}

MaterialPageRoute<void> createSaveTrackRoute(OnTrackSaveHandler trackHandler) {
  return new MaterialPageRoute<void>(builder: (BuildContext context) {
    return new NewTrackPage(trackHandler: trackHandler);
  });
}

typedef Future<void> OnTrackDataSaveHandler(TrackData trackData);

class NewTrackDataPage extends StatefulWidget {
  final Track currentTrack;
  final OnTrackDataSaveHandler trackDataHandler;

  NewTrackDataPage(this.currentTrack, this.trackDataHandler);

  @override
  State<StatefulWidget> createState() => NewTrackDataPageState(currentTrack, trackDataHandler);
}

class NewTrackDataPageState extends State<NewTrackDataPage> {
  final Track currentTrack;
  final OnTrackDataSaveHandler trackDataHandler;

  //mutable state
  TrackData newTrackData;

  NewTrackDataPageState(this.currentTrack, this.trackDataHandler) {
    newTrackData = new TrackData(track: currentTrack, time: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text("Track Data Entry")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          // hide the software keyboard
          await trackDataHandler(newTrackData);
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
      ),
      body: new Column(children: <Widget>[
        new Expanded(
            child: TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: 'Value'),
          onChanged: (data) => newTrackData.value = double.parse(data),
        ))
      ]),
    );
  }
}

MaterialPageRoute<void> createSaveTrackDataRoute(Track currentTrack, OnTrackDataSaveHandler trackDataHandler) {
  return new MaterialPageRoute<void>(builder: (BuildContext context) {
    return new NewTrackDataPage(currentTrack, trackDataHandler);
  });
}

enum ChoiceActionType {
  NEW_TRACK, OTHER
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'New Track', icon: Icons.playlist_add, actionType: ChoiceActionType.NEW_TRACK),
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
  final PageController controller = new PageController();

  // mutable state
  final List<Track> tracks = new List<Track>();
  int currentTrackIndex = 0;

  TracksPageState(this.dbConnection) {}

  @override
  void initState() {
    super.initState();

    dbConnection.getTracks().then((newTracks) {
      setState(() {
        tracks.addAll(newTracks);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Scaffold(
        resizeToAvoidBottomPadding:
            false, //this prevents this widget from resizing due to software keyboard (which would cause problems)
        appBar: new AppBar(
          title: Text("Bismuth"),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(choices[0].icon),
              onPressed: () {
                _onChoice(choices[0], context);
              },
            ),
            // action button
            IconButton(
              icon: Icon(choices[1].icon),
              onPressed: () {
                _onChoice(choices[1], context);
              },
            ),
            // overflow menu
            PopupMenuButton<Choice>(
              onSelected: (choice) => _onChoice(choice, context),
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
          onPressed: () => _AddEntryPressed(context),
        ),
        body: new Stack(children: <Widget>[
          _buildPageView(),
          new Positioned.fill(
              right: windowSize.width - 50,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.blue),
                onPressed: () {
                  controller.previousPage(
                      duration: const Duration(microseconds: 100), curve: const ElasticInOutCurve());
                },
              )),
          new Positioned.fill(
              left: windowSize.width - 50,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.blue),
                onPressed: () {
                  controller.nextPage(duration: const Duration(microseconds: 100), curve: const ElasticInOutCurve());
                },
              )),
        ]
            //new CircleIndicator(controller, tracks.length, 3.0, Colors.white70, Colors.white)
            ));
  }

  Widget _buildPageView() {
    if (tracks.isEmpty) {
      return const Center(
          child: const Text(
        "Add tracks using the toolbar.",
        textAlign: TextAlign.center,
      ));
    }
    return new PageView.builder(
      controller: controller,
      onPageChanged: (index) {
        currentTrackIndex = index;
        pageIndexNotifier.value = index;
      },
      itemCount: tracks.length,
      itemBuilder: (context, index) => new TrackPage(track: tracks[index], dbConnection: dbConnection),
    );
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

  void _AddEntryPressed(BuildContext context) {
    if (tracks.isEmpty) {
      return;
    }

    final track = tracks[currentTrackIndex];
    Navigator.of(context).push(createSaveTrackDataRoute(track, (newTrackData) async {
          await dbConnection.putTrackData(newTrackData);
          setState(() {
            tracks[currentTrackIndex].trackData.add(newTrackData);
          });
        }));
  }

  void _onChoice(Choice choice, BuildContext context) {
    if (choice.actionType == ChoiceActionType.NEW_TRACK) {
      Navigator.of(context).push(createSaveTrackRoute((newTrack) {
        dbConnection.putTrack(newTrack);
        setState(() {
          tracks.add(newTrack);
          // this is buggy
          if (tracks.length > 1) {
            controller.jumpToPage(tracks.length - 1);
          }
        });
      }));
    }
  }
}
