import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future<String> get _documentsPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> get _bismuthStoragePath async {
  final path = await _documentsPath;
  return '$path/bismuth.db';
}

class BismuthDbConnection {
  final Database _db;

  static Future<BismuthDbConnection> openConnection() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(await _bismuthStoragePath);
    return new BismuthDbConnection(db);
  }
  BismuthDbConnection(this._db);

  Future<void> initHello() async {
    await _db.put('test', 'first');
  }

  Future<String> getHello() async {
    return await _db.get('first') as String;
  }
}
