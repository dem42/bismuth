import 'dart:async';

import 'package:bismuth/choice.dart';
import 'package:bismuth/data_base.dart';
import 'package:bismuth/model/group.dart';
import 'package:bismuth/model/track.dart';
import 'package:bismuth/new_group_popup.dart';
import 'package:bismuth/new_track_data_popup.dart';
import 'package:bismuth/new_track_popup.dart';
import 'package:bismuth/track_page.dart';
import 'package:flutter/material.dart';
import 'package:page_view_indicator/page_view_indicator.dart';

class TracksSwipePage extends StatefulWidget {
  final BismuthDbConnection dbConnection;

  TracksSwipePage(this.dbConnection);

  @override
  State<StatefulWidget> createState() => TracksPageState(dbConnection);
}

class TracksPageState extends State<TracksSwipePage> {
  final ValueNotifier<int> pageIndexNotifier = ValueNotifier<int>(0);
  final BismuthDbConnection dbConnection;
  final PageController controller = new PageController(keepPage: false);

  // mutable state
  final List<Track> tracks = new List<Track>();
  final List<Group> groups = new List<Group>();
  int currentTrackIndex = 0;

  TracksPageState(this.dbConnection) {}

  @override
  void initState() {
    super.initState();

    dbConnection.getGroups().then((newGroups) {
      dbConnection.getTracks(groups: newGroups).then((newTracks) {
          setState(() {
            tracks.addAll(newTracks);
            tracks.sort(Track.SORTER);
            groups.addAll(newGroups);
            groups.sort((g1, g2) => g1.order - g2.order);
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    return new Scaffold(
        resizeToAvoidBottomPadding:
        false, //this prevents this widget from resizing due to software keyboard (which would cause problems)
        appBar: new AppBar(
          title: Text("Git Gud"),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(choices[0].icon),
              onPressed: () {
                _onChoice(choices[0], context);
              },
            ),
            // action button
            IconButton(
              icon: Icon(choices[1].icon),
              onPressed: () {
                _onChoice(choices[1], context);
              },
            ),
            // overflow menu
            PopupMenuButton<Choice>(
              onSelected: (choice) => _onChoice(choice, context),
              itemBuilder: (BuildContext context) {
                return choices.skip(2).map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () => _addEntryPressed(context),
        ),
        body: new Stack(children: <Widget>[
          _buildPageView(),
          new Positioned.fill(
              right: windowSize.width - 50,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.blue),
                onPressed: () async {
                  await controller.previousPage(
                      duration: const Duration(microseconds: 200), curve: const ElasticInOutCurve());
                },
              )),
          new Positioned.fill(
              left: windowSize.width - 50,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.blue),
                onPressed: () async {
                  await controller.nextPage(
                      duration: const Duration(microseconds: 200), curve: const ElasticInOutCurve());
                },
              )),
        ]
          //new CircleIndicator(controller, tracks.length, 3.0, Colors.white70, Colors.white)
        ));
  }

  Widget _buildPageView() {
    if (tracks.isEmpty) {
      return const Center(
          child: const Text(
            "Add tracks using the toolbar.",
            textAlign: TextAlign.center,
          ));
    }
    return new PageView.builder(
      controller: controller,
      onPageChanged: (index) {
        currentTrackIndex = index;
        pageIndexNotifier.value = index;
      },
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        return new TrackPage(track: tracks[index], dbConnection: dbConnection);
      },
    );
  }

  Widget _createPageIndicator(ValueNotifier<int> pageIndexNotifier, int length) {
    return PageViewIndicator(
      pageIndexNotifier: pageIndexNotifier,
      length: length,
      normalBuilder: (animationController) => Circle(
        size: 8.0,
        color: Colors.black87,
      ),
      highlightedBuilder: (animationController) => ScaleTransition(
        scale: CurvedAnimation(
          parent: animationController,
          curve: Curves.ease,
        ),
        child: Circle(
          size: 12.0,
          color: Colors.black45,
        ),
      ),
    );
  }

  void _addEntryPressed(BuildContext context) {
    if (tracks.isEmpty) {
      return;
    }

    final track = tracks[currentTrackIndex];
    Navigator.of(context).push(createSaveTrackDataRoute(track, (newTrackData) {
      if (!newTrackData.isValid()) {
        return;
      }
      dbConnection.putTrackData(newTrackData);
      setState(() {
        tracks[currentTrackIndex].trackData.add(newTrackData);
      });
    }));
  }

  void _onChoice(Choice choice, BuildContext context) async {
    switch (choice.actionType) {
      case ChoiceActionType.NEW_TRACK:
        _onNewTrackAction(context);
        break;
      case ChoiceActionType.DELETE_TRACK:
        if (tracks.isEmpty) {
          return;
        }
        await _onDeleteTrackAction();
        break;
      case ChoiceActionType.CLEAR_DB:
        setState(() {
          tracks.clear();
          groups.removeRange(1, groups.length);
          dbConnection.clearDb();
        });
        break;
      case ChoiceActionType.NEW_GROUP:
        _onNewGroupAction();
        break;
      case ChoiceActionType.DELETE_GROUP:
        break;
      case ChoiceActionType.OTHER:
        assert(false);
    }
  }

  Future<void> _onDeleteTrackAction() async {
    final trackToRemove = tracks[currentTrackIndex];
    final indexRemoved = currentTrackIndex;
    if (tracks.length > 1) {
      if (currentTrackIndex > 0)
        await controller.previousPage(
            duration: const Duration(microseconds: 200), curve: const ElasticInOutCurve());
      else if (tracks.length == 2)
        await controller.nextPage(duration: const Duration(microseconds: 200), curve: const ElasticInOutCurve());
      else {
        // haha nice code flutter
        controller.jumpToPage(indexRemoved+1);
        await controller.previousPage(duration: const Duration(microseconds: 200), curve: const ElasticInOutCurve());
      }
    }
    dbConnection.removeTrack(trackToRemove);

    setState(() {
      tracks.removeAt(indexRemoved);
      if (tracks.isEmpty) {
        currentTrackIndex = 0;
      } else if (indexRemoved > 0) {
        currentTrackIndex = indexRemoved - 1;
      } else {
        currentTrackIndex = indexRemoved;
      }
    });
  }

  void _onNewTrackAction(BuildContext context) {
    Navigator.of(context).push(createSaveTrackRoute(groups, (newTrack) {
      if (!newTrack.isValid()) {
        return;
      }
      dbConnection.putTrack(newTrack);
      setState(() {
        tracks.add(newTrack);
        tracks.sort(Track.SORTER);
        var newIdx = tracks.indexOf(newTrack);
        if (tracks.length > 1) {
          controller.jumpToPage(newIdx);
        }
        currentTrackIndex = newIdx;
      });
    }));
  }

  void _onNewGroupAction() async {
    Navigator.of(context).push(createSaveGroupRoute((newGroup) {
      if (!newGroup.isValid()) {
        return;
      }
      newGroup.order = groups.isEmpty ? 1 : groups.last.order + 1;
      dbConnection.putGroup(newGroup);
      setState(() {
        groups.add(newGroup);
      });
    }));
  }
}