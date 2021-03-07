import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speaker_recognizer/simple.dart';
import 'package:speaker_recognizer/speaker_json.dart';

class SpeakerEditor extends StatefulWidget {
  const SpeakerEditor({Key? key}) : super(key: key);

  @override
  _SpeakerEditorState createState() => _SpeakerEditorState();
}

class _SpeakerEditorState extends State<SpeakerEditor> {
  static final _logTag = "$SpeakerEditor";

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nickController = TextEditingController();
  final _ageController = TextEditingController();

  String? _sex;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildNickNameField() {
    final nick = TextFormField(
      controller: _nickController,
      decoration: InputDecoration(
        hintText: "Type a name",
        labelText: "Name",
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]"))
      ],
      validator: (value) {
        return (value?.isEmpty ?? true) ? "Please enter some text" : null;
      },
      onChanged: (text) {
        _idController.text = "${text.toLowerCase()}-${Simple.id(4)}";
      },
    );

    return ListTile(title: nick);
  }

  Widget _buildAgeField() {
    final age = TextFormField(
      controller: _ageController,
      decoration: InputDecoration(labelText: "Age"),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.singleLineFormatter,
      ],
      validator: (value) {
        return (value?.isEmpty ?? true) ? "Please enter a number" : null;
      },
    );

    return ListTile(title: age);
  }

  Widget _buildGenderField() {
    final sex = DropdownButtonFormField<String>(
      value: _sex,
      decoration: InputDecoration(hintText: "Sex"),
      onChanged: (newValue) {
        setState(() {
          _sex = newValue;
        });
      },
      items: [
        DropdownMenuItem(
          value: "male",
          child: Text("Male"),
        ),
        DropdownMenuItem(
          value: "female",
          child: Text("Female"),
        ),
      ],
      validator: (value) {
        return (value?.isEmpty ?? true) ? "Set this field" : null;
      },
    );

    return ListTile(title: sex);
  }

  Widget _buildSpeakerId() {
    final id = TextFormField(
      controller: _idController,
      enabled: false,
      decoration: InputDecoration(
        labelText: "Id",
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.allow(RegExp(r"[a-f0-9]"))
      ],
      validator: (value) {
        return (value?.isEmpty ?? true) ? "Please enter a id" : null;
      },
    );

    return ListTile(title: id);
  }

  void _submit() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    final speaker = Speaker(
      id: _idController.text,
      age: int.parse(_ageController.text),
      name: _nickController.text,
      sex: _sex!,
    );

    final query = FirebaseFirestore.instance
        .collection("speaker").doc(speaker.id);

    await query.set(speaker.toMap());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speaker"),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          _buildSpeakerId(),
          _buildNickNameField(),
          _buildAgeField(),
          _buildGenderField(),
          TextButton(
            child: Text("Submit"),
            onPressed: _submit,
          )
        ]),
      ),
    );
  }
}
