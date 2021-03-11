import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:speaker_recognizer/recording_json.dart';
import 'package:just_audio/just_audio.dart' as ap;

class RecordingListener extends StatefulWidget {
  RecordingListener({Key? key}) : super(key: key);

  @override
  _RecordingListenerState createState() => _RecordingListenerState();
}

class _RecordingListenerState extends State<RecordingListener> {
  static final _logTag = "$RecordingListener";

  final _player = ap.AudioPlayer();
  final _recordingsRef = FirebaseStorage.instance.ref();

  List<Recording> _recordings = [];

  void _parseList(List<QueryDocumentSnapshot>? docs) {
    log("_parseList: docs=${docs?.length}", name: _logTag);

    final list = <Recording>[];

    docs?.forEach((doc) {
      log("_parseList: doc.id=${doc.id}", name: _logTag);

      final data = doc.data();

      if (data == null) {
        return;
      }

      final recording = Recording.fromMap(data);
      list.add(recording);
    });

    setState(() {
      _recordings = list;
    });
  }

  @override
  void initState() {
    super.initState();

    log("initState:", name: _logTag);

    Query query = FirebaseFirestore.instance.collection("recordings");
    query = query.orderBy("Created", descending: true);

    final snap = query.snapshots();
    snap.listen((event) => _parseList(event.docs));
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recordings"),
      ),
      body: ListView.builder(
        itemCount: _recordings.length,
        itemBuilder: (ctx, inx) {
          final recording = _recordings[inx];

          final ref = _recordingsRef.child("${recording.storagePath}");

          final title = ListTile(
            title: Text(
              recording.phrase,
              // style: Theme.of(context).textTheme.headline6,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // leading: Icon(Icons.play_arrow),
            // leading: Text(recording.speakerId),
            subtitle: Wrap(
              spacing: 20,
              children: [
                Text(recording.id),
                Text(recording.speakerId),
                Text(recording.setId),
              ],
            ),
            onTap: () async {
              final url = await ref.getDownloadURL();
              _player.setUrl(url);
              _player.play();
            },
            onLongPress: () {
              ref.delete();
              final doc = FirebaseFirestore.instance
                  .collection("recordings")
                  .doc(recording.id);

              doc.delete();
            },
          );

          return title;
        },
      ),
    );
  }
}
