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
  State<StatefulWidget> createState() {
    return new TrackPageState(track: track, dbConnection: dbConnection);
  }
}

class TrackPageState extends State<TrackPage> {
  static const _GRAPH_HEIGHT_PROPORTION = 0.55;
  static const _LIST_HEIGHT_PROPORTION = 0.60;
  static const _GRAPH_WIDTH_PROPORTION = 0.80;

  final BismuthDbConnection dbConnection;
  final TextStyle headerTextStyle = new TextStyle(fontWeight: FontWeight.bold);

  // mutable state
  final Track track;
  //final List<TrackData> trackData = new List<TrackData>();

  TrackPageState({@required this.track, @required this.dbConnection});

//  @override
//  void initState() {
//    super.initState();
//
//    dbConnection.getTrackData(track).then((newTrackData) {
//      setState(() {
//        trackData.addAll(newTrackData);
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text("Track: ${track.name}"),
          new Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _createChart(),
              height: windowSize.height * _GRAPH_HEIGHT_PROPORTION,
              width: windowSize.width * _GRAPH_WIDTH_PROPORTION),
          new Expanded(
              child: new Container(
                  width: windowSize.width * _LIST_HEIGHT_PROPORTION,
                  child: new TrackDataListView(
                    trackData: track.trackData,
                    headerTextStyle: headerTextStyle,
                    onDelete: _deleteTrackData,
                  )))
          //new Text("hello"),
        ],
      ),
    );
  }

  Widget _createChart() {
    if (track.trackData.isEmpty) {
      return const Center(
          child: const Text(
        "No data available.\nUse the + button to add data.",
        textAlign: TextAlign.center,
      ));
    } else {
      return SimpleTimeSeriesChart.fromData(track.trackData);
    }
  }

  void _deleteTrackData(TrackData trackData) {
    setState(() {
      track.trackData.remove(trackData);
    });
    dbConnection.removeTrackData(trackData);
  }
}

class TrackDataListView extends StatelessWidget {
  const TrackDataListView({Key key, @required this.trackData, @required this.headerTextStyle, @required this.onDelete})
      : super(key: key);

  final List<TrackData> trackData;
  final TextStyle headerTextStyle;
  final OnDelete onDelete;

  @override
  Widget build(BuildContext context) {
    if (trackData.isEmpty) {
      return new Container();
    }

    return new ListView.builder(
        padding: const EdgeInsets.all(0.0),
        itemCount: 2 * (trackData.length + 1),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;

          if (i == 0) {
            return new TrackListViewHeaderRow(headerTextStyle: headerTextStyle);
          }

          final td = trackData[index - 1];
          return new TrackListViewDataRow(td: td, onDelete: onDelete);
        });
  }
}

typedef void OnDelete(TrackData trackData);

class TrackListViewDataRow extends StatelessWidget {
  const TrackListViewDataRow({Key key, @required this.td, @required this.onDelete}) : super(key: key);

  final TrackData td;
  final OnDelete onDelete;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    const popupRectSize = 100;
    final menuPopupPos = RelativeRect.fromLTRB(
        windowSize.width / 2.0 - popupRectSize,
        windowSize.height / 2.0 - popupRectSize,
        windowSize.width / 2.0 - popupRectSize,
        windowSize.height / 2.0 - popupRectSize);
    return new GestureDetector(
        onLongPress: () async {
          String selected = await showMenu<String>(position: menuPopupPos, context: context, items: <PopupMenuEntry<String>>[
            new PopupMenuItem(
              value: "selected", //this is absolutely crucial or else there is no callback
              child: Text("Delete: ${_formatDataTime(td.time)}:${td.value}"),
            )
          ]);
          if (selected != null) {
            onDelete(td);
          }
        },
        child: new Row(
          children: <Widget>[
            new Text(_formatDataTime(td.time)),
            new Expanded(child: new Text(td.value.toString(), textAlign: TextAlign.right))
          ],
        ));
  }

  String _formatDataTime(String time) {
    final DateTime dt = DateTime.parse(time);
    return "${dt.year.toString()}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";
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
