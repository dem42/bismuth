import 'dart:async';
import 'package:bismuth/model/track.dart';
import 'package:flutter/material.dart';
import 'data_base.dart';
import 'charts.dart';
import 'package:page_view_indicator/page_view_indicator.dart';

Future<void> main() async {
  final dbConnection = await BismuthDbConnection.openConnection();

  //await dbConnection.initHello();

  runApp(new BismuthApp());
}

typedef Widget ChartBuilder(Track track);
typedef void Action(BuildContext context);

class TrackPage extends StatelessWidget {
  final ChartBuilder chartBuilder;
  final Track track;

  TrackPage({this.chartBuilder, this.track});

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: chartBuilder(track),
              height: windowSize.height * 0.8,
              width: windowSize.width * 0.8),
          //new Text("hello"),
        ],
      ),
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

List<Choice> choices = <Choice>[
  Choice(
      title: 'New Track',
      icon: Icons.add,
      action: (context) {
        Navigator
            .of(context)
            .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(title: const Text("New Track")),
            body: new Stack(
                alignment: FractionalOffset.bottomCenter,
                children: <Widget>[
                  new Text("hmm"),
                  new IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () => Navigator.of(context).pop())
                ]),
          );
        }));
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
        body: new Stack(
            alignment: FractionalOffset.bottomCenter,
            children: <Widget>[
              new PageView(
                onPageChanged: (index) => pageIndexNotifier.value = index,
                children: <Widget>[
                  new TrackPage(
                      chartBuilder: (track) =>
                          SimpleTimeSeriesChart.withSampleData(),
                      track: null),
                  new TrackPage(
                      chartBuilder: (track) =>
                          SimpleTimeSeriesChart.withSampleData2(),
                      track: null),
                ],
              ),
              _createPageIndicator(pageIndexNotifier, 2)
            ]));
  }

  Widget _createPageIndicator(
      ValueNotifier<int> pageIndexNotifier, int length) {
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
