import 'package:bismuth/model/track.dart';

class TrackData {
  final String time;
  final num value;
  final String trackName;

  TrackData({Track track, DateTime time, this.value}) : trackName = track.name, time = time.toIso8601String();

  TrackData.fromJson(Map<String, dynamic> json)
      : trackName = json['trackName'],
        time = json['time'],
        value = json['value'];

  Map<String, dynamic> toJson() =>
      {
        'trackName': trackName,
        'time': time,
        'value': value,
      };
}