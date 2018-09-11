import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track_data.dart';

class Track {
  String name;
  String groupName;
  Group _group;
  final String units;
  final List<TrackData> trackData = new List<TrackData>();
  final int timestamp;

  static int Function(Track a, Track b) SORTER = (a, b) {
    if (a.group.order != b.group.order) return a.group.order.compareTo(b.group.order);
    return a.timestamp.compareTo(b.timestamp);
  };

  set group(Group group) {
    this._group = group;
    this.groupName = group.name;
  }
  Group get group => _group;

  Track({this.name, Group group, this.units, this.timestamp}) {
    if (group != null) {
      this.group = group;
    }
  }

  Track.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        groupName = json['groupName'],
        units = json['units'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'groupName': groupName,
        'units': units,
        'timestamp': timestamp,
      };

  bool isValid() {
    return name != null && name.isNotEmpty;
  }
}