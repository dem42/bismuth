import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/indicator_settings.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future<String> get _documentsPath async {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return ".";
  }
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> get _bismuthStoragePath async {
  final path = await _documentsPath;
  return '$path/bismuth.db';
}

class BismuthDbConnection {
  final Database _db;
  static const String _GROUP_STRORE_KEY = "groups";
  static const String _TRACK_STRORE_KEY = "tracks";
  static const String _TRACK_DATA_STRORE_KEY = "track_data";
  static const String _INDICATOR_STRORE_KEY = "indicator_data";
  static const String _INDICATOR_KEY = "graph_indicator";

  static Future<BismuthDbConnection> openConnection() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(await _bismuthStoragePath);
    return new BismuthDbConnection(db);
  }
  BismuthDbConnection(this._db);

  Future<void> initTestData() async {
    Group g1 = new Group(name: "testG", order: 1);
    Group g2 = new Group(name: "gunit", order: 2);

    await putGroup(g1);
    await putGroup(g2);

    Track t1 = new Track(name: "weight", group: g1, units: "kg");
    Track t2 = new Track(name: "test", group: g2, units: "hops");
    Track t3 = new Track(name: "test2", group: g2, units: "hops");

    await putTrack(t1);
    await putTrack(t2);
    await putTrack(t3);

    TrackData td1 = new TrackData(track: t1, time: new DateTime(2017, 10, 18), value: 10);
    TrackData td2 = new TrackData(track: t1, time: new DateTime(2017, 10, 25), value: 100);
    TrackData td3 = new TrackData(track: t1, time: new DateTime(2017, 11, 13), value: 50);

    TrackData td4 = new TrackData(track: t2, time: new DateTime(2018, 1, 10), value: 50);
    TrackData td5 = new TrackData(track: t2, time: new DateTime(2018, 1, 15), value: 60);
    TrackData td6 = new TrackData(track: t2, time: new DateTime(2018, 2, 1), value: 70);
    TrackData td7 = new TrackData(track: t2, time: new DateTime(2018, 2, 16), value: 65);

    await putTrackData(td1);
    await putTrackData(td2);
    await putTrackData(td3);

    await putTrackData(td4);
    await putTrackData(td5);
    await putTrackData(td6);
    await putTrackData(td7);
  }

  Future<void> putGroup(Group group) async {
    final store = _db.getStore(_GROUP_STRORE_KEY);
    await store.put(json.encode(group), group.name);
  }

  Future<void> removeGroup(Group group) async {
    return;
  }

  Future<List<Group>> getGroups() async {
    final store = _db.getStore(_GROUP_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    var allGroups = records.map((record) => Group.fromJson(json.decode(record.value))).toList();
    allGroups.insert(0, Group.DEFAULT_GROUP);
    return allGroups;
  }

  Future<void> putTrack(Track track) async {
    final store = _db.getStore(_TRACK_STRORE_KEY);
    await store.put(json.encode(track), track.name);
    for(var td in track.trackData) {
      await putTrackData(td);
    }
  }

  Future<void> removeTrack(Track track) async {
    final store = _db.getStore(_TRACK_STRORE_KEY);
    await store.delete(track.name);
    for(var td in track.trackData) {
      await removeTrackData(td);
    }
  }

  Future<List<Track>> getTracks({List<Group> groups}) async {
    if (groups == null || groups.isEmpty) {
      groups = await getGroups();
    }
    final store = _db.getStore(_TRACK_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    var tracks = records.map((record) => Track.fromJson(json.decode(record.value))).toList();
    for (var track in tracks) {
      var dumbCompiler = (Group g) {return g.name == track.groupName;};
      track.group = groups.where(dumbCompiler).first;
      final td = await getTrackData(track);
      track.trackData.addAll(td);
    }
    return tracks;
  }

  Future<void> putTrackData(TrackData trackData) async {
    final store = _db.getStore(_TRACK_DATA_STRORE_KEY);
    await store.put(json.encode(trackData), trackData.primaryKey);
  }

  Future<void> removeTrackData(TrackData trackData) async {
    final store = _db.getStore(_TRACK_DATA_STRORE_KEY);
    await store.delete(trackData.primaryKey);
  }

  Future<List<TrackData>> getTrackData(Track track) async {
    final store = _db.getStore(_TRACK_DATA_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    var result = records.map((record) => TrackData.fromJson(json.decode(record.value))).toList();
    result.retainWhere((trackData) => trackData.trackName == track.name);
    return result;
  }

  Future<void> clearDb() async {
    final storeTd = _db.getStore(_TRACK_DATA_STRORE_KEY);
    await storeTd.clear();
    final storeTracks = _db.getStore(_TRACK_STRORE_KEY);
    await storeTracks.clear();
    final storeGroup = _db.getStore(_GROUP_STRORE_KEY);
    await storeGroup.clear();
    final indicatorGroup = _db.getStore(_INDICATOR_STRORE_KEY);
    await indicatorGroup.clear();
  }

  Future<void> updateIndicator(IndicatorSettings settings) async {
    final store = _db.getStore(_INDICATOR_STRORE_KEY);
    await store.put(json.encode(settings), _INDICATOR_KEY);
  }

  Future<IndicatorSettings> getIndicator() async {
    final store = _db.getStore(_INDICATOR_STRORE_KEY);
    var indicator = IndicatorSettings.fromJson(json.decode(await store.get(_INDICATOR_KEY)) as Map<String, dynamic>);
    if (indicator == null) {
      indicator = new IndicatorSettings();
    }
    return indicator;
  }
}
