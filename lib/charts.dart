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

  factory SimpleTimeSeriesChart.fromData(List<TrackData> trackData) {
    final data = trackData.map((td) => new TDSeries(DateTime.parse(td.time), td.value)).toList();

    final series = [
      new charts.Series(
          id: 'Data',
          data: data,
          // two __ or else it thinks it's the same name
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TDSeries sales, _) => sales.time,
          measureFn: (TDSeries sales, _) => sales.value)
    ];

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

class TDSeries {
  final DateTime time;
  final num value;

  TDSeries(this.time, this.value);
}
