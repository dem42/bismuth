import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:bismuth/model/group.dart';
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

  static Future<BismuthDbConnection> openConnection() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(await _bismuthStoragePath);
    return new BismuthDbConnection(db);
  }
  BismuthDbConnection(this._db);

  Future<void> putGroup(Group group) async {
    final store = _db.getStore(_GROUP_STRORE_KEY);
    await store.put(json.encode(group), group.name);
  }

  Future<List<Group>> getGroups() async {
    final store = _db.getStore(_GROUP_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    return records.map((record) => Group.fromJson(json.decode(record.value))).toList();
  }

  Future<void> putTrack(Track track) async {
    final store = _db.getStore(_TRACK_STRORE_KEY);
    await store.put(json.encode(track), track.name);
  }

  Future<List<Track>> getTracks() async {
    final store = _db.getStore(_TRACK_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    return records.map((record) => Track.fromJson(json.decode(record.value))).toList();
  }

  Future<void> putTrackData(TrackData trackData) async {
    final store = _db.getStore(_TRACK_DATA_STRORE_KEY);
    await store.put(json.encode(trackData), trackData.time);
  }

  Future<List<TrackData>> getTrackData() async {
    final store = _db.getStore(_TRACK_DATA_STRORE_KEY);
    Finder finder = new Finder();
    var records = await store.findRecords(finder);
    return records.map((record) => TrackData.fromJson(json.decode(record.value))).toList();
  }
}
