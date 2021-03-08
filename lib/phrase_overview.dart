import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:speaker_recognizer/recorder.dart';
import 'package:speaker_recognizer/speaker_json.dart';

class PhraseOverview extends StatefulWidget {
  final Speaker speaker;

  const PhraseOverview({Key? key, required this.speaker}) : super(key: key);

  @override
  _PhraseOverviewState createState() => _PhraseOverviewState();
}

class _PhraseOverviewState extends State<PhraseOverview> {
  static final _logTag = "$PhraseOverview";

  List<PhraseSet>? _sets;

  @override
  void initState() {
    super.initState();

    Phrases.fetch().then((value) {
      setState(() {
        _sets = value;
      });
    });
  }

  void _openRecorder(PhraseSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordStream(
          speaker: widget.speaker,
          phrases: set.phrases,
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_sets == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _sets!.length,
      itemBuilder: (ctx, inx) {
        return ListTile(
          title: Text(_sets![inx].title),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () => _openRecorder(_sets![inx]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speaker.name),
      ),
      body: _buildList(),
    );
  }
}

class PhraseSet {
  PhraseSet({
    required this.id,
    required this.title,
    required this.language,
    required this.phrases,
  });

  final String id;
  final String title;
  final String language;
  final List<String> phrases;

  factory PhraseSet.fromJson(String str) => PhraseSet.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PhraseSet.fromMap(Map<String, dynamic> json) => PhraseSet(
        id: json["Id"],
        title: json["Title"],
        language: json["Language"],
        phrases: List<String>.from(json["Phrases"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Title": title,
        "Language": language,
        "Phrases": List<dynamic>.from(phrases.map((x) => x)),
      };
}

class Phrases {
  static List<PhraseSet> _sets = [];

  static Future<List<PhraseSet>> fetch() async {
    if (_sets.isNotEmpty) {
      return _sets;
    }

    Reference ref = FirebaseStorage.instance.ref().child("phrases.json");

    final data = await ref.getData();

    if (data == null) {
      return [];
    }

    final list = List<dynamic>.from(jsonDecode(utf8.decode(data)));

    list.forEach((element) {
      _sets.add(PhraseSet.fromMap(element));
    });

    return _sets;
  }
}
