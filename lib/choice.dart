import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon, this.actionType = ChoiceActionType.OTHER});

  final String title;
  final IconData icon;
  final ChoiceActionType actionType;
}

enum ChoiceActionType { NEW_TRACK, DELETE_TRACK, CLEAR_DB, NEW_GROUP, DELETE_GROUP, OTHER }

const List<Choice> choices = const <Choice>[
  const Choice(title: 'New Track', icon: Icons.playlist_add, actionType: ChoiceActionType.NEW_TRACK),
  const Choice(title: 'New Group', icon: Icons.add_shopping_cart, actionType: ChoiceActionType.NEW_GROUP),
  const Choice(title: 'Delete Track', icon: Icons.remove, actionType: ChoiceActionType.DELETE_TRACK),
  const Choice(title: 'Delete Group', icon: Icons.remove_shopping_cart, actionType: ChoiceActionType.DELETE_GROUP),
  const Choice(title: 'Clear Database', icon: Icons.warning, actionType: ChoiceActionType.CLEAR_DB),
];