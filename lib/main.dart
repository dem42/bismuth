import 'dart:async';
import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'data_base.dart';
import 'charts.dart';
import 'package:page_view_indicator/page_view_indicator.dart';

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

  runApp(new BismuthApp());
}

typedef Widget ChartBuilder(Track track);
typedef void Action(BuildContext context);

class TrackPage extends StatelessWidget {
  final ChartBuilder chartBuilder;
  final Track track;
  final List<TrackData> trackData;
  final TextStyle headerTextStyle = new TextStyle(fontWeight: FontWeight.bold);

  TrackPage({this.chartBuilder, this.track, this.trackData = const []});

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(child: chartBuilder(track), height: windowSize.height * 0.65, width: windowSize.width * 0.8),
          new Expanded(
              child: new Container(
                  width: windowSize.width * 0.5,
                  child: new TrackDataListView(trackData: trackData, headerTextStyle: headerTextStyle)))
          //new Text("hello"),
        ],
      ),
    );
  }
}

class TrackDataListView extends StatelessWidget {
  const TrackDataListView({
    Key key,
    @required this.trackData,
    @required this.headerTextStyle,
  }) : super(key: key);

  final List<TrackData> trackData;
  final TextStyle headerTextStyle;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: trackData.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return new TrackListViewHeaderRow(headerTextStyle: headerTextStyle);
          }

          final td = trackData[index - 1];
          return new TrackListViewDataRow(td: td);
        });
  }
}

class TrackListViewDataRow extends StatelessWidget {
  const TrackListViewDataRow({
    Key key,
    @required this.td,
  }) : super(key: key);

  final TrackData td;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Text(td.time),
        new Expanded(child: new Text(td.value.toString(), textAlign: TextAlign.right))
      ],
    );
  }
}

class TrackListViewHeaderRow extends StatelessWidget {
  const TrackListViewHeaderRow({
    Key key,
    @required this.headerTextStyle,
  }) : super(key: key);

  final TextStyle headerTextStyle;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Text("Date", style: headerTextStyle),
        new Expanded(child: new Text("Value", style: headerTextStyle, textAlign: TextAlign.right))
      ],
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bismuth',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new TracksPage(),
    );
  }
}

class TracksPage extends StatelessWidget {
  final ValueNotifier<int> pageIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false, //this prevents this widget from resizing due to software keyboard (which would cause problems)
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
              child: new PageView(
            onPageChanged: (index) => pageIndexNotifier.value = index,
            children: <Widget>[
              new TrackPage(
                chartBuilder: (track) => SimpleTimeSeriesChart.withSampleData(),
                track: t1,
                trackData: tds,
              ),
              new TrackPage(chartBuilder: (track) => SimpleTimeSeriesChart.withSampleData(), track: t1),
            ],
          )),
          _createPageIndicator(pageIndexNotifier, 2)
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
