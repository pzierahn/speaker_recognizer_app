import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speaker_recognizer/file_uploader.dart';
import 'package:speaker_recognizer/phrase_overview.dart';
import 'package:speaker_recognizer/recorder_page.dart';
import 'package:speaker_recognizer/recording_json.dart';
import 'package:speaker_recognizer/simple.dart';
import 'package:speaker_recognizer/speaker_json.dart';

class RecordStream extends StatefulWidget {
  final Speaker speaker;
  final PhraseSet phrasesSet;

  const RecordStream({
    Key? key,
    required this.speaker,
    required this.phrasesSet,
  }) : super(key: key);

  @override
  _RecordStreamState createState() => _RecordStreamState();
}

class _RecordStreamState extends State<RecordStream> {
  static final _logTag = "$RecordStream";

  String? _path;

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        _path = dir.path;
      });
    });
  }

  Widget _buildElem(BuildContext ctx, int inx) {
    String speakerId = widget.speaker.id;

    String phraseSetId = widget.phrasesSet.id;

    String audioId = Simple.id(12);
    String audioName = "$speakerId.$audioId.m4a";

    String localPath = "$_path/$audioName";

    String phrase = widget.phrasesSet.phrases[inx];

    final recording = Recording(
      id: audioId,
      speakerId: speakerId,
      setId: phraseSetId,
      phrase: phrase,
      audioPath: "recordings/$audioName"
    );

    return RecorderPage(
      phrase: phrase,
      audioPath: localPath,
      onUpload: (upload) {
        if (upload) {
          RecordingUploader.post(localPath, recording);
        } else {
          File(localPath).delete();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speaker.name),
      ),
      body: (_path == null)
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: widget.phrasesSet.phrases.length,
              scrollDirection: Axis.vertical,
              itemBuilder: _buildElem,
            ),
    );
  }
}
