import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await storage.ref("tweezes/$fileName").putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downloadURL(String imageName) async {
    String downloadURL = await storage.ref('test/$imageName').getDownloadURL();

    return downloadURL;
  }
}
