import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {

  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(_createSampleData(), animate: false,);
  }

  factory SimpleTimeSeriesChart.withSampleData2() {
    return new SimpleTimeSeriesChart(_createSampleData2(), animate: false,);
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(seriesList, animate: animate, dateTimeFactory: const charts.LocalDateTimeFactory(),);
  }

  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 16), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series(id: 'Sales',
          data: data,
          // two __ or else it thinks it's the same name
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales)
    ];
  }

  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData2() {
    final data = [
      new TimeSeriesSales(new DateTime(2018, 9, 16), 5),
      new TimeSeriesSales(new DateTime(2018, 9, 26), 10),
    ];

    return [
      new charts.Series(id: 'Sales',
          data: data,
          // two __ or else it thinks it's the same name
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales)
    ];
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
