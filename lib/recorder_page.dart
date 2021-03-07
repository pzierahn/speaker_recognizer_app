import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:record/record.dart';
import 'package:speaker_recognizer/file_uploader.dart';
import 'package:speaker_recognizer/audio_player.dart';
import 'package:speaker_recognizer/recording_json.dart';
import 'package:speaker_recognizer/simple.dart';
import 'package:speaker_recognizer/speaker_json.dart';

import 'dart:io' as io;

class RecorderPage extends StatefulWidget {
  final Speaker speaker;
  final String phrase;
  final String audioPath;

  const RecorderPage({
    Key? key,
    required this.speaker,
    required this.phrase,
    required this.audioPath,
  }) : super(key: key);

  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  static final _logTag = "$RecorderPage";

  bool _isRecording = false;

  String? _audioId;
  String? _audioName;
  String? _path;

  Recording? _recording;

  @override
  void initState() {
    super.initState();

    _audioId = Simple.id(12);
    _audioName = "${widget.speaker.id}.$_audioId.m4a";
    _path = "${widget.audioPath}/$_audioName";

    _recording = Recording(
      id: _audioId!,
      speakerId: widget.speaker.id,
      audio: _audioName!,
      language: "de",
      text: widget.phrase,
    );

    log("initState: _audioId=$_audioId", name: _logTag);
    log("initState: _audioName=$_audioName", name: _logTag);
  }

  Future<void> _start() async {
    log("_start: _path=${_path!}", name: _logTag);

    try {
      if (await Record.hasPermission()) {
        await Record.start(
          path: _path!,
          samplingRate: 48000,
        );

        bool isRecording = await Record.isRecording();
        setState(() {
          _isRecording = isRecording;
        });
      }
    } catch (e) {
      log("_start: exc $e", name: _logTag);
    }
  }

  Future<void> _stop() async {
    log("_stop:", name: _logTag);

    await Record.stop();

    setState(() {
      _isRecording = false;
    });

    _showMyDialog();
  }

  Future<void> _showMyDialog() async {
    bool? upload = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Upload sample"),
          content: SingleChildScrollView(
            child: AudioPlayer(
              path: _path!,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Upload"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    log("_showMyDialog: upload=$upload", name: _logTag);

    if (upload ?? false) {
      FileUploader.upload(_recording!, _path!);
    } else {
      _deleteFile();
    }
  }

  Future<void> _deleteFile() async {
    await io.File(_path!).delete();
  }

  Future<void> _cancel() async {
    log("_cancel:", name: _logTag);

    final snackBar = SnackBar(content: Text("Cancel recording"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await Record.stop();

    setState(() {
      _isRecording = false;
    });

    await _deleteFile();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ListTile(
          title: Text(
            widget.phrase,
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .headline5!
                .copyWith(
              color: _isRecording ? Colors.green : null,
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (details) {
            log("build: onTapDown", name: _logTag);
            _start();
          },
          onTapUp: (details) {
            log("build: onTapUp", name: _logTag);
            _stop();
          },
          onTapCancel: () {
            log("build: onTapCancel", name: _logTag);
            _cancel();
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: _isRecording
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
            child: Center(
                child: Icon(
                  Icons.mic,
                  size: 50,
                )),
          ),
        ),
      ],
    );
  }
}
