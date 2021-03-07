import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speaker_recognizer/recorder_page.dart';
import 'package:speaker_recognizer/speaker_json.dart';

class RecordStream extends StatefulWidget {
  final Speaker speaker;
  final List<String> phrases;

  const RecordStream({
    Key? key,
    required this.speaker,
    required this.phrases,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speaker.name),
      ),
      body: (_path == null)
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: widget.phrases.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, inx) {
                return RecorderPage(
                  speaker: widget.speaker,
                  phrase: widget.phrases[inx],
                  audioPath: _path!,
                );
              },
            ),
    );
  }
}
