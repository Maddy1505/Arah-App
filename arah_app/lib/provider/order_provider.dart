import 'package:flutter/material.dart';

class OrderModel {
  final String title;
  final String price;
  final String clientInitial;
  final String clientName;
  final String status;

  OrderModel(this.title, this.price, this.clientInitial, this.clientName, this.status);
}

class OrderProvider with ChangeNotifier {
  final List<OrderModel> _activeOrders = [
    OrderModel("Python script for data scraping", "\$120", "A", "Alex Johnson", "Pending"),
    OrderModel("Design mobile app mockups", "\$350", "S", "Sarah Williams", "Pending"),
  ];

  final List<OrderModel> _completedOrders = [
    OrderModel("Write 3 blog posts about AI", "\$75", "M", "Michael Scott", "Completed"),
  ];

  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get completedOrders => _completedOrders;
}
