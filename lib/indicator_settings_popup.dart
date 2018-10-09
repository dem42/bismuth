import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/indicator_settings.dart';
import 'package:bismuth/fade_transition_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void OnIndicatorSettingsUpdate(IndicatorSettings indicatorSettings);

class IndicatorSettingsPage extends StatefulWidget {
  final IndicatorSettings indicatorSettings;
  final OnIndicatorSettingsUpdate handler;

  IndicatorSettingsPage({@required this.indicatorSettings, @required this.handler});

  @override
  State<StatefulWidget> createState() =>
      IndicatorSettingsPageState(indicatorSettings: indicatorSettings, handler: handler);
}

class IndicatorSettingsPageState extends State<IndicatorSettingsPage> {
  final OnIndicatorSettingsUpdate handler;
  final IndicatorSettings indicatorSettings = new IndicatorSettings();

  IndicatorSettingsPageState({@required IndicatorSettings indicatorSettings, @required this.handler}) {
    // copy the values from the passed in indicator settings
    this.indicatorSettings.showMovingAvg = indicatorSettings?.showMovingAvg ?? false;
    this.indicatorSettings.movingAvgDays = indicatorSettings?.movingAvgDays ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(title: const Text("Indicator Settings")),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.save),
        onPressed: () async {
          handler(indicatorSettings);
          Navigator.of(context).pop();
        },
      ),
      body: new Container(
          padding: EdgeInsets.all(size.height / 10),
          child: new Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            new Container(
                margin: EdgeInsets.only(bottom: size.height / 20),
                child: const Text("Here you can configure settings for graph indicators:")),
            new Row(children: <Widget>[
              new Container(margin: const EdgeInsets.only(right: 10.0), child: const Text("Show Moving Avg:")),
              new Checkbox(
                value: indicatorSettings.showMovingAvg,
                onChanged: (newShowMavg) {
                  setState(() {
                    indicatorSettings.showMovingAvg = newShowMavg;
                  });
                },
              )
            ]),
            new Row(children: <Widget>[
//              new Container(padding: const EdgeInsets.only(right: 10.0), child:
              new Container(margin: const EdgeInsets.only(right: 10.0), child: const Text("Moving Avg Days:")),
              new Expanded(
                  child: new TextField(
                      decoration: InputDecoration(hintText: "${indicatorSettings?.movingAvgDays ?? 0}"),
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (data) {
                        setState(() {
                          indicatorSettings.movingAvgDays = int.parse(data);
                        });
                      }))
            ])
          ])),
    );
  }
}

MaterialPageRoute<void> createIndicatorSettingsRoute(IndicatorSettings settings, OnIndicatorSettingsUpdate handler) {
  return new FadeTransitionRoute<void>(builder: (BuildContext context) {
    return new IndicatorSettingsPage(indicatorSettings: settings, handler: handler);
  });
}
