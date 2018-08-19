import 'package:bismuth/charts.dart';
import 'package:bismuth/data_base.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:flutter/material.dart';

typedef Widget ChartBuilder(Track track);

class TrackPage extends StatefulWidget {

  final Track track;
  final BismuthDbConnection dbConnection;

  TrackPage({this.track, this.dbConnection});

  @override
  State<StatefulWidget> createState() => TrackPageState(track: track, dbConnection: dbConnection);
}

class TrackPageState extends State<TrackPage> {
  final Track track;
  final BismuthDbConnection dbConnection;
  final TextStyle headerTextStyle = new TextStyle(fontWeight: FontWeight.bold);

  // mutable state
  final List<TrackData> trackData = new List<TrackData>();

  TrackPageState({@required this.track, @required this.dbConnection});

  @override
  void initState() {
    dbConnection.getTrackData(track).then((newTrackData) {
      setState(() {
        trackData.addAll(newTrackData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(child: _createChart(), height: windowSize.height * 0.65, width: windowSize.width * 0.8),
          new Expanded(
              child: new Container(
                  width: windowSize.width * 0.5,
                  child: new TrackDataListView(trackData: trackData, headerTextStyle: headerTextStyle)))
          //new Text("hello"),
        ],
      ),
    );
  }

  Widget _createChart() {
    if (trackData.isEmpty) {
      return const Center(child: const Text("No data available"));
    }
    else {
      return SimpleTimeSeriesChart.fromData(trackData);
    }
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