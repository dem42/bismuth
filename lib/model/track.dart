import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track_data.dart';

class Track {
  String name;
  String groupName;
  Group _group;
  final String units;
  final bool hasMovingAverage;
  final int movingAvgDays;
  final List<TrackData> trackData = new List<TrackData>();
  final int timestamp;

  set group(Group group) {
    this._group = group;
    this.groupName = group.name;
  }
  Group get group => _group;

  Track({this.name, Group group, this.units, this.hasMovingAverage = false, this.movingAvgDays = 0, this.timestamp}) {
    if (group != null) {
      this.group = group;
    }
  }

  Track.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        groupName = json['groupName'],
        units = json['units'],
        hasMovingAverage = json['hasMovingAverage'],
        movingAvgDays = json['movingAvgDays'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'groupName': groupName,
        'units': units,
        'hasMovingAverage': hasMovingAverage,
        'movingAvgDays': movingAvgDays,
        'timestamp': timestamp,
      };

  bool isValid() {
    return name != null && name.isNotEmpty;
  }
}