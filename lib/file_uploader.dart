import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speaker_recognizer/recording_json.dart';

class FileUploader {
  static final _logTag = "$FileUploader";

  static Future<UploadTask?> _uploadAudio(String path, String filename) async {
    log("_uploadFile: path=$path", name: _logTag);

    final ref =
        FirebaseStorage.instance.ref().child("recordings").child("/$filename");
    final metadata = SettableMetadata(
      contentType: "audio/aac",
    );

    final file = File(path);
    final len = await file.length();

    if (len <= 0) {
      return null;
    }

    log("_uploadFile: file.length=$len", name: _logTag);

    final task = ref.putFile(file, metadata);
    return Future.value(task);
  }

  static void upload(Recording recording, String path) async {
    final task = await _uploadAudio(path, recording.audio);

    task?.then((event) {
      final state = event.state;
      log("upload: state=$state", name: _logTag);

      if (state == TaskState.success) {
        final ref = FirebaseFirestore.instance
            .collection("recordings")
            .doc(recording.id);

        ref.set(recording.toMap());

        File(path).delete();
      }
    });
  }
}
