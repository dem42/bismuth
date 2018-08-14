import 'dart:async';
import 'package:flutter/material.dart';
import 'fileUtils.dart';
import 'charts.dart';

Future<void> main() async {

  final dbConnection = await BismuthDbConnection.openConnection();

  //await dbConnection.initHello();

  var msg = await dbConnection.getHello();

  runApp(new MyApp(msg));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final String text;

  MyApp(this.text);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bismuth',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: Text('Bismuth'),),
        body: new Center(
          child: SimpleTimeSeriesChart.withSampleData(),
        )
      )
    );
  }
}
