import 'dart:async';

import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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