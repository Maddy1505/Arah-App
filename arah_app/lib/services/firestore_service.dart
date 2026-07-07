import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';

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

  // Fetch Chat Rooms for User
  Stream<List<ChatRoom>> fetchChatRooms(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create or Get Chat Room
  Future<String> createOrGetChatRoom(String user1Id, String user2Id) async {
    List<String> uids = [user1Id, user2Id];
    uids.sort();
    String chatId = "${uids[0]}_${uids[1]}";

    final docRef = _db.collection('chats').doc(chatId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'participants': [user1Id, user2Id],
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {user1Id: 0, user2Id: 0},
      });
    }

    return chatId;
  }

  // Fetch Chat Messages
  Stream<List<Message>> fetchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Send Message
  Future<void> sendMessage(String chatId, Message message, String receiverId) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');

    await messagesRef.add(message.toMap());

    await chatRef.update({
      'lastMessage': message.type == MessageType.text ? message.content : 'Attachment',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadCounts.$receiverId': FieldValue.increment(1),
    });
  }

  // Mark Messages as Read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.update({
      'unreadCounts.$userId': 0,
    });
  }
}
