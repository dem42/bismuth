import 'dart:convert';
import 'package:bismuth/data_base.dart';
import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/model/track_data.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {

  Group g1 = new Group(name: "testG", order: 1);
  Group g2 = new Group(name: "gunit", order: 2);

  Track t1 = new Track(name: "weight", group: g1, units: "kg", hasMovingAverage: true, movingAvgDays: 10);
  Track t2 = new Track(name: "test", group: g2, units: "hops");
  Track t3 = new Track(name: "test2", group: g2, units: "hops");

  TrackData td1 = new TrackData(track: t1, time: new DateTime(2018, 1, 1), value: 10);
  TrackData td2 = new TrackData(track: t1, time: new DateTime(2018, 1, 2), value: 10);
  TrackData td3 = new TrackData(track: t2, time: new DateTime(2018, 1, 3), value: 10);

  test("SerializationTest", () {
    String group1 = json.encode(g1);
    expect(group1, '{"name":"testG","order":1}');

    Group decodedg1 = Group.fromJson(json.decode(group1));
    expect(decodedg1.name, g1.name);
    expect(decodedg1.order, g1.order);
  });

  test("Data storage and retrieval of groups", () async {
    final db = await BismuthDbConnection.openConnection();
    await db.putGroup(g1);
    await db.putGroup(g2);
    var groups = await db.getGroups();
    for (var group in groups) {
      print(group.name);
    }
  });

  test("Data storage and retrieval of tracks", () async {
    final db = await BismuthDbConnection.openConnection();
    await db.putTrack(t1);
    await db.putTrack(t2);
    var tracks = await db.getTracks();
    for (var track in tracks) {
      print(track.name);
    }
  });

  test("Data storage and retrieval of track data", () async {
    final db = await BismuthDbConnection.openConnection();
    await db.putTrackData(td1);
    await db.putTrackData(td2);
    await db.putTrackData(td3);
    var trackData = await db.getTrackData(t1);
    for (var td in trackData) {
      print(td.time);
    }
  });
}