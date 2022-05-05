import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      TaskSnapshot uploadTask =
          await storage.ref("tweezes/$fileName").putFile(file);
      String url = await (await uploadTask).ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      return e.toString();
    }
  }
}
