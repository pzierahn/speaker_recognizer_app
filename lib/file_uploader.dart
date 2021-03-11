import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speaker_recognizer/recording_json.dart';

class RecordingUploader {
  static final _logTag = "$RecordingUploader";

  static Future<UploadTask?> _uploadAudio(String src, String filename) async {
    log("_uploadFile: path=$src", name: _logTag);

    final ref =
        FirebaseStorage.instance.ref().child("$filename");
    final metadata = SettableMetadata(
      contentType: "audio/aac",
    );

    final file = File(src);
    final len = await file.length();

    if (len <= 0) {
      return null;
    }

    log("_uploadFile: file.length=$len", name: _logTag);

    final task = ref.putFile(file, metadata);
    return Future.value(task);
  }

  static void post(String path, Recording recording) async {
    final task = await _uploadAudio(path, recording.storagePath);

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
