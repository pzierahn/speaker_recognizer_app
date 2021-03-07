import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  Recording({
    required this.id,
    required this.speakerId,
    required this.audio,
    required this.language,
    required this.text,
    Timestamp? date,
  }) : date = date ?? Timestamp.now();

  final Timestamp date;

  final String id;
  final String speakerId;
  final String audio;
  final String language;
  final String text;

  factory Recording.fromJson(String str) => Recording.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Recording.fromMap(Map<String, dynamic> json) => Recording(
        date: json["Date"] == null ? null : json["Date"],
        id: json["ID"] == null ? null : json["ID"],
        speakerId: json["SpeakerId"] == null ? null : json["SpeakerId"],
        audio: json["Audio"] == null ? null : json["Audio"],
        language: json["Language"] == null ? null : json["Language"],
        text: json["Text"] == null ? null : json["Text"],
      );

  Map<String, dynamic> toMap() => {
        "Date": date,
        "ID": id,
        "SpeakerId": speakerId,
        "Audio": audio,
        "Language": language,
        "Text": text,
      };
}
