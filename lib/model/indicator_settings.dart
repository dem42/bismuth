class IndicatorSettings {
  bool showMovingAvg;
  int movingAvgDays;

  IndicatorSettings({this.showMovingAvg = false, this.movingAvgDays = 0});

  IndicatorSettings.fromJson(Map<String, dynamic> json)
      : showMovingAvg = json['showMovingAvg'],
        movingAvgDays = json['movingAvgDays'];

  Map<String, dynamic> toJson() =>
      {
        'showMovingAvg': showMovingAvg,
        'movingAvgDays': movingAvgDays,
      };

  bool isValid() {
    return showMovingAvg != null && movingAvgDays != null;
  }
}