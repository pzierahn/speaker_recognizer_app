import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  Recording({
    required this.id,
    required this.speakerId,
    required this.setId,
    required this.phrase,
    required this.storagePath,
    Timestamp? created,
  }) : created = created ?? Timestamp.now();

  final String id;
  final Timestamp created;
  final String speakerId;
  final String setId;
  final String phrase;
  final String storagePath;

  factory Recording.fromJson(String str) => Recording.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Recording.fromMap(Map<String, dynamic> json) => Recording(
        id: json["Id"],
        speakerId: json["SpeakerId"],
        setId: json["SetId"],
        phrase: json["Phrase"],
        created: json["Created"] == null ? null : json["Created"],
        storagePath: json["StoragePath"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Created": created,
        "SpeakerId": speakerId,
        "SetId": setId,
        "Phrase": phrase,
        "StoragePath": storagePath,
      };
}
