import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String uid, String filePath) async {
    Reference ref = _storage.ref().child('profile_pics/$uid.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<String> uploadTaskAttachment(String taskId, String filePath) async {
    String fileName = filePath.split(RegExp(r'[/\\]')).last;
    Reference ref = _storage.ref().child('task_attachments/$taskId/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<String> uploadChatAttachment(String chatId, String filePath) async {
    String fileName = filePath.split(RegExp(r'[/\\]')).last;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('chats/$chatId/${timestamp}_$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
