import 'dart:collection';

import 'package:bismuth/model/indicator_settings.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      animate: false,
    );
  }

  factory SimpleTimeSeriesChart.fromData(List<TrackData> trackData, {IndicatorSettings indicatorSettings}) {
    List<TrackData> sorted = List.of(trackData, growable: false);
    sorted.sort((t1, t2) => -t2.datetime.compareTo(t1.datetime));
    final data = sorted.map((td) => new TDSeries(td.datetime, td.value)).toList();

    final series = [
      new charts.Series(
          id: 'Data',
          data: data,
          // two __ or else it thinks it's the same name
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TDSeries sales, _) => sales.time,
          measureFn: (TDSeries sales, _) => sales.value)
    ];

    if (indicatorSettings?.showMovingAvg ?? false) {
      final dataForMvAvg = _computeMovingAvgSeries(data, indicatorSettings.movingAvgDays);
      final dashedPattern = List.generate(dataForMvAvg.length, (_) => 2);
      series.add(new charts.Series(
          id: "mavg_${indicatorSettings.movingAvgDays}_day",
          data: dataForMvAvg,
          // two __ or else it thinks it's the same name
          dashPatternFn: (_, __) => dashedPattern,
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (TDSeries sales, _) => sales.time,
          measureFn: (TDSeries sales, _) => sales.value));
    }

    return new SimpleTimeSeriesChart(
      series,
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(seriesList,
        animate: animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        defaultRenderer: new charts.LineRendererConfig(includePoints: true),
        primaryMeasureAxis:
            new charts.NumericAxisSpec(tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false)));
  }

  static List<charts.Series<TDSeries, DateTime>> _createSampleData() {
    final data = [
      new TDSeries(new DateTime(2017, 9, 16), 5),
      new TDSeries(new DateTime(2017, 9, 26), 25),
      new TDSeries(new DateTime(2017, 10, 3), 100),
      new TDSeries(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series(
          id: 'Sales',
          data: data,
          // two __ or else it thinks it's the same name
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TDSeries sales, _) => sales.time,
          measureFn: (TDSeries sales, _) => sales.value)
    ];
  }
}

List<TDSeries> _computeMovingAvgSeries(List<TDSeries> data, int movingAvgDays) {
  num sum = 0;
  List<TDSeries> newData = new List<TDSeries>();
  Queue<TDSeries> window = new Queue<TDSeries>();
  for (TDSeries sEnt in data) {
    while (window.isNotEmpty && sEnt.time.difference(window.first.time).inDays > movingAvgDays) {
      sum = sum - window.first.value;
      window.removeFirst();
    }
    sum += sEnt.value;
    window.add(sEnt);
    newData.add(new TDSeries(sEnt.time, sum / window.length));
  }
  return newData;
}

class TDSeries {
  final DateTime time;
  final num value;

  TDSeries(this.time, this.value);
}
