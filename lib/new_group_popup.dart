import 'package:bismuth/model/group.dart';
import 'package:bismuth/fade_transition_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void OnGroupSaveHandler(Group group);

@immutable
class NewGroupPage extends StatelessWidget {
  final OnGroupSaveHandler groupHandler;
  final Group newGroup = new Group();

  NewGroupPage({Key key, this.groupHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(title: const Text("New Group")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          groupHandler(newGroup);
          await SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop();
        },
      ),
      body: new Container(padding: EdgeInsets.all(size.height / 10), child: new Column(children: <Widget>[
        new Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Name'),
              onChanged: (newName) => newGroup.name = newName,
            ))
      ])),
    );
  }
}

MaterialPageRoute<void> createSaveGroupRoute(OnGroupSaveHandler groupHandler) {
  return new FadeTransitionRoute<void>(builder: (BuildContext context) {
    return new NewGroupPage(groupHandler: groupHandler);
  });
}