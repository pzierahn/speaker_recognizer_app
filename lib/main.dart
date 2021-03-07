import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speaker_recognizer/phrase_overview.dart';
import 'package:speaker_recognizer/recorder.dart';
import 'package:speaker_recognizer/recording_listener.dart';
import 'package:speaker_recognizer/speaker_edit.dart';
import 'package:speaker_recognizer/speaker_json.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Speaker Recognizer",
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryIconTheme: IconThemeData(color: Colors.black),
          primaryTextTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          appBarTheme: AppBarTheme(
            brightness: Brightness.light,
            elevation: 0.5,
            color: Colors.white,
          )),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final _logTag = "$MyHomePage";

  List<Speaker> _speaker = [];

  void _openRecorder(Speaker speaker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => RecordStream(
        builder: (context) => PhraseOverview(
          speaker: speaker,
        ),
      ),
    );
  }

  void _parseSpeaker(List<QueryDocumentSnapshot>? docs) {
    log("_parseSpeaker: docs=${docs?.length}", name: _logTag);

    final list = <Speaker>[];

    docs?.forEach((doc) {
      log("initState: doc.id=${doc.id}", name: _logTag);

      final data = doc.data();

      if (data == null) {
        return;
      }

      final speaker = Speaker.fromMap(data);
      list.add(speaker);
    });

    list.sort((spe1, spe2){
      return spe2.name.compareTo(spe1.name);
    });

    setState(() {
      _speaker = list;
    });
  }

  @override
  void initState() {
    super.initState();

    log("initState:", name: _logTag);

    Query query = FirebaseFirestore.instance.collection("speaker");
    final snap = query.snapshots();
    snap.listen((event) => _parseSpeaker(event.docs));
  }

  void _createSpeaker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeakerEditor(),
      ),
    );
  }

  void _openRecordings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingListener(),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = "https://avataaars.io/"
        "?avatarStyle=Circle"
        "&topType=Hat&accessoriesType=Blank"
        "&facialHairType=Blank"
        "&clotheType=BlazerSweater"
        "&eyeType=WinkWacky"
        "&eyebrowType=UpDown"
        "&mouthType=Smile"
        "&skinColor=Light";

    return SvgPicture.network(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _speaker.length + 2,
        itemBuilder: (ctx, inx) {
          if (inx == _speaker.length) {
            return ListTile(
              title: Center(
                child: TextButton(
                  child: Text("Create speaker"),
                  onPressed: _createSpeaker,
                ),
              ),
            );
          }

          if (inx == _speaker.length + 1) {
            return ListTile(
              title: Center(
                child: TextButton(
                  child: Text("Recordings"),
                  onPressed: _openRecordings,
                ),
              ),
            );
          }

          final title = ListTile(
            title: Text(
              _speaker[inx].name,
              style: Theme.of(context).textTheme.headline6,
            ),
            // leading: _buildAvatar(),
            trailing: Icon(Icons.keyboard_arrow_right),
            subtitle: Text("${_speaker[inx].id}"),
            onTap: () => _openRecorder(_speaker[inx]),
          );

          final card = Card(
            child: title,
          );

          return card;
        },
      ),
    );
  }
}
