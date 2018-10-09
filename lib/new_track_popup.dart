import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/fade_transition_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void OnTrackSaveHandler(Track track);

class NewTrackPage extends StatefulWidget {
  final List<Group> groups;
  final OnTrackSaveHandler trackHandler;

  NewTrackPage({this.groups, this.trackHandler});

  @override
  State<StatefulWidget> createState() => NewTrackPageState(groups: groups, trackHandler: trackHandler);
}

class NewTrackPageState extends State<NewTrackPage> {
  final OnTrackSaveHandler trackHandler;
  final List<Group> groups;

  final Track newTrack = new Track(units: "units", timestamp: DateTime.now().millisecondsSinceEpoch);

  NewTrackPageState({this.trackHandler, this.groups}) {
    newTrack.group = groups[0];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
      body: new Container(padding: EdgeInsets.all(size.height / 10), child: new Column(children: <Widget>[
        new Container(padding: EdgeInsets.only(bottom: size.height / 10), child: TextField(
          decoration: InputDecoration(hintText: 'Name'),
          onChanged: (newName) => newTrack.name = newName,
        )),
        Row(children: <Widget>[
          new Container(child: const Text("Group:"), margin: const EdgeInsets.only(right: 5.0),),
          new DropdownButton<String>(
            value: newTrack.groupName,
            items: groups.map((Group value) {
              return new DropdownMenuItem<String>(
                value: value.name,
                child: new Container(width: size.width / 3, child: new Text(value.name, textAlign: TextAlign.center,)),
              );
            }).toList(),
            onChanged: (groupName) {
              setState(() {
                var dumbCompiler = (Group g) {
                  return g.name == groupName;
                };
                newTrack.group = groups.where(dumbCompiler).first;
              });
            },
          ),
        ])
      ])),
    );
  }
}

MaterialPageRoute<void> createSaveTrackRoute(List<Group> groups, OnTrackSaveHandler trackHandler) {
  return new FadeTransitionRoute<void>(builder: (BuildContext context) {
    return new NewTrackPage(groups: groups, trackHandler: trackHandler);
  });
}
