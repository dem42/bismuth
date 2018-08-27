import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track_data.dart';

class Track {
  String name;
  final String groupName;
  final String units;
  final bool hasMovingAverage;
  final int movingAvgDays;
  final List<TrackData> trackData = new List<TrackData>();

  Track({this.name, Group group, this.units, this.hasMovingAverage = false, this.movingAvgDays = 0}) : groupName = group.name;

  Track.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        groupName = json['groupName'],
        units = json['units'],
        hasMovingAverage = json['hasMovingAverage'],
        movingAvgDays = json['movingAvgDays'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'groupName': groupName,
        'units': units,
        'hasMovingAverage': hasMovingAverage,
        'movingAvgDays': movingAvgDays,
      };

  bool isValid() {
    return name != null && name.isNotEmpty;
  }
}