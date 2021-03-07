import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speaker_recognizer/audio_player.dart';

class AudioRecorder extends StatefulWidget {
  final String path;
  final VoidCallback onStop;

  const AudioRecorder({
    required this.path,
    required this.onStop,
  });

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  static const int maxDuration = 120;

  bool _isRecording = false;
  int _remainingDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    _isRecording = false;
    _remainingDuration = maxDuration;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildControl(),
            SizedBox(width: 20),
            _buildText(),
          ],
        ),
      ),
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_isRecording) {
      icon = Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            if (_isRecording) {
              _stop();
            } else {
              _start();
            }
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording) {
      return _buildTimer();
    }

    return Text("Waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_remainingDuration ~/ 60);
    final String seconds = _formatNumber(_remainingDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<void> _start() async {
    try {
      if (await Record.hasPermission()) {
        await Record.start(
          path: widget.path,
          samplingRate: 48000,
        );

        bool isRecording = await Record.isRecording();
        setState(() {
          _isRecording = isRecording;
          _remainingDuration = maxDuration;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    await Record.stop();

    setState(() {
      _isRecording = false;
      _remainingDuration = maxDuration;
    });

    widget.onStop();
  }

  void _startTimer() {
    const tick = const Duration(milliseconds: 500);

    _timer?.cancel();

    _timer = Timer.periodic(tick, (Timer t) async {
      if (!_isRecording) {
        t.cancel();
      } else {
        setState(() {
          _remainingDuration = maxDuration - (t.tick / 2).floor();
        });

        if (_remainingDuration <= 0) {
          _stop();
        }
      }
    });
  }
}

class RecordMain extends StatefulWidget {
  @override
  _RecordMainState createState() => _RecordMainState();
}

class _RecordMainState extends State<RecordMain> {
  bool showPlayer = false;
  String? path;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recorder"),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: getPath(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (showPlayer) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: AudioPlayer(
                    path: snapshot.data!,
                    // onDelete: () {
                    //   setState(() => showPlayer = false);
                    // },
                  ),
                );
              } else {
                return AudioRecorder(
                  path: snapshot.data!,
                  onStop: () {
                    setState(() => showPlayer = true);
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<String> getPath() async {
    if (path == null) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.m4a';
    }

    return path!;
  }
}
