import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class OrderModel {
  final String id;
  final String title;
  final String price;
  final String clientInitial;
  final String clientName;
  final String clientId; // The other party's UID (seller's buyerId or buyer's sellerId)
  final String status;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String taskId;
  final String chatId;
  final bool ratedByBuyer;
  final bool ratedBySeller;

  OrderModel({
    this.id = '',
    required this.title,
    required this.price,
    required this.clientInitial,
    required this.clientName,
    this.clientId = '',
    required this.status,
    this.buyerId = '',
    this.buyerName = '',
    this.sellerId = '',
    this.sellerName = '',
    this.taskId = '',
    this.chatId = '',
    this.ratedByBuyer = false,
    this.ratedBySeller = false,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final clientName = map['clientName'] ?? 'Unknown';
    return OrderModel(
      id: id,
      title: map['title'] ?? '',
      price: map['price'] ?? '₹0',
      clientInitial:
          clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
      clientName: clientName,
      clientId: map['clientId'] ?? '',
      status: map['status'] ?? 'Pending',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      taskId: map['taskId'] ?? '',
      chatId: map['chatId'] ?? '',
      ratedByBuyer: map['ratedByBuyer'] ?? false,
      ratedBySeller: map['ratedBySeller'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'clientName': clientName,
      'clientId': clientId,
      'status': status,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'taskId': taskId,
      'chatId': chatId,
      'ratedByBuyer': ratedByBuyer,
      'ratedBySeller': ratedBySeller,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class OrderProvider with ChangeNotifier {
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _completedOrders = [];
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  bool get isLoading => _isLoading;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get completedOrders => _completedOrders;

  /// Subscribe to orders from Firestore for the given user
  void subscribeToOrders(String uid, {bool isSeller = false}) {
    _isLoading = true;
    notifyListeners();

    final activeStream = isSeller
        ? _firestoreService.fetchSellerOrders(uid, ['Pending', 'PendingApproval']) 
        : _firestoreService.fetchUserOrders(uid, ['Pending', 'PendingApproval']);

    final completedStream = isSeller
        ? _firestoreService.fetchSellerOrders(uid, ['Completed', 'Rejected'])
        : _firestoreService.fetchUserOrders(uid, ['Completed', 'Rejected']);

    activeStream.listen((snap) {
      _activeOrders = snap.docs
          .map((d) =>
              OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('OrderProvider active stream error: $e');
      _isLoading = false;
      notifyListeners();
    });

    completedStream.listen((snap) {
      _completedOrders = snap.docs
          .map((d) =>
              OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('OrderProvider completed stream error: $e');
    });
  }

  /// Mark order as completed: updates order status + task status
  Future<void> completeOrder(String orderId, String taskId) async {
    try {
      await _firestoreService.completeOrder(orderId, taskId);
    } catch (e) {
      debugPrint('completeOrder error: $e');
    }
  }

  /// Accept an order request
  Future<void> acceptOrder(String orderId) async {
    try {
      await _firestoreService.acceptOrderRequest(orderId);
    } catch (e) {
      debugPrint('acceptOrder error: $e');
    }
  }

  /// Reject an order request
  Future<void> rejectOrder(String orderId) async {
    try {
      await _firestoreService.rejectOrderRequest(orderId);
    } catch (e) {
      debugPrint('rejectOrder error: $e');
    }
  }

  /// Reassign: delete order + reset task to "open"
  Future<void> reassignOrder(String orderId, String taskId) async {
    try {
      await _firestoreService.reassignTask(orderId, taskId);
    } catch (e) {
      debugPrint('reassignOrder error: $e');
    }
  }

  /// Save a rating for the other party
  Future<void> saveRating({
    required String orderId,
    required String ratedUserId,
    required String raterId,
    required double rating,
    required bool isBuyerRating,
    String reviewText = '',
  }) async {
    try {
      await _firestoreService.saveRating(
        orderId: orderId,
        ratedUserId: ratedUserId,
        raterId: raterId,
        rating: rating,
        isBuyerRating: isBuyerRating,
        reviewText: reviewText,
      );
    } catch (e) {
      debugPrint('saveRating error: $e');
    }
  }
}
