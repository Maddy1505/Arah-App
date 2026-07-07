import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create User Profile
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Fetch Tasks for Seller Workspace
  Stream<QuerySnapshot> fetchOpenTasks() {
    return _db
        .collection('tasks')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Post a Request (Buyer)
  Future<void> createTask(Map<String, dynamic> taskData) async {
    await _db.collection('tasks').add(taskData);
  }

  // Fetch User Orders
  Stream<QuerySnapshot> fetchUserOrders(String uid, String status) {
    return _db
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // Fetch Chat Messages
  Stream<QuerySnapshot> fetchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
