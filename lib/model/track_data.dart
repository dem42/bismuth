import 'package:bismuth/model/track.dart';

class TrackData {
  final String time;
  num value;
  final String trackName;
  DateTime _datetime;

  TrackData({Track track, DateTime time, this.value}) : trackName = track.name, time = time.toIso8601String(), _datetime = time;

  TrackData.fromJson(Map<String, dynamic> json)
      : trackName = json['trackName'],
        time = json['time'],
        value = json['value'];

  DateTime get datetime {
    if (_datetime == null) {
      _datetime = DateTime.parse(time);
    }
    return _datetime;
  }

  Map<String, dynamic> toJson() =>
      {
        'trackName': trackName,
        'time': time,
        'value': value,
      };

  bool isValid() {
    return value != null;
  }

  String get primaryKey => "$trackName:$time";
}