import 'dart:async';
import 'package:bismuth/tracks_swipe_page.dart';
import 'package:flutter/material.dart';
import 'package:bismuth/data_base.dart';

Future<void> main() async {
  final dbConnection = await BismuthDbConnection.openConnection();

  //await dbConnection.initHello();
  //await dbConnection.initTestData();

  //debugPaintSizeEnabled = true;

  runApp(new BismuthApp(dbConnection));
}

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
      home: new TracksSwipePage(dbConnection),
    );
  }
}