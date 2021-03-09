import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:record/record.dart';
import 'package:speaker_recognizer/audio_player.dart';
import 'package:speaker_recognizer/recording_json.dart';

import 'dart:io' as io;

class RecorderPage extends StatefulWidget {
  final String phrase;
  final String audioPath;
  final ValueChanged<bool> onUpload;

  const RecorderPage({
    Key? key,
    required this.phrase,
    required this.audioPath,
    required this.onUpload,
  }) : super(key: key);

  @override
  _RecorderPageState createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  static final _logTag = "$RecorderPage";

  bool _isRecording = false;


  Recording? _recording;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _start() async {
    log("_start: audioPath=${widget.audioPath}", name: _logTag);

    try {
      if (await Record.hasPermission()) {
        await Record.start(
          path: widget.audioPath,
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
              path: widget.audioPath,
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

    widget.onUpload(upload ?? false);
  }

  Future<void> _deleteFile() async {
    await io.File(widget.audioPath).delete();
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
