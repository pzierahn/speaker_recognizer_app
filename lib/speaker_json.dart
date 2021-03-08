import 'dart:convert';

class Speakers {
  Speakers({
    List<Speaker>? speaker,
  }) : speaker = speaker ?? [];

  final List<Speaker> speaker;

  factory Speakers.fromJson(String str) => Speakers.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Speakers.fromMap(Map<String, dynamic> json) => Speakers(
        speaker: json["speaker"] == null
            ? null
            : List<Speaker>.from(
                json["speaker"].map((x) => Speaker.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "speaker": List<dynamic>.from(speaker.map((x) => x.toMap())),
      };
}

class Speaker {
  Speaker({
    required this.id,
    required this.age,
    required this.name,
    required this.sex,
  });

  final String id;
  final int age;
  final String name;
  final String sex;

  factory Speaker.fromJson(String str) => Speaker.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Speaker.fromMap(Map<String, dynamic> json) => Speaker(
        id: json["Id"] == null ? null : json["Id"],
        age: json["Age"] == null ? null : json["Age"],
        name: json["Name"] == null ? null : json["Name"],
        sex: json["Sex"] == null ? null : json["Sex"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Age": age,
        "Name": name,
        "Sex": sex,
      };
}
