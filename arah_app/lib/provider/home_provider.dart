import 'package:flutter/material.dart';

// Buyer Task Model
class TaskModel {
  final String category;
  final String price;
  final String title;
  final bool isBeginnerFriendly;
  final String postedTime;

  TaskModel(
    this.category,
    this.price,
    this.title,
    this.isBeginnerFriendly,
    this.postedTime,
  );
}

// Seller Task Model
class SellerTaskModel {
  final String title;
  final String price;
  final List<String> tags;
  final String dueTime;

  SellerTaskModel(this.title, this.price, this.tags, this.dueTime);
}

class HomeProvider with ChangeNotifier {
  String _selectedCategory = "All";
  
  final List<TaskModel> _allTasks = [
    TaskModel(
      "Design",
      "\$50",
      "Need a logo for my startup",
      true,
      "Posted 5 mins ago",
    ),
    TaskModel(
      "Development",
      "\$120",
      "Python script for data scraping",
      false,
      "Posted 1 hour ago",
    ),
    TaskModel(
      "Writing",
      "\$75",
      "Write 3 blog posts about AI",
      true,
      "Posted 3 hours ago",
    ),
    TaskModel(
      "Development",
      "\$30",
      "Fix a bug in my React app",
      false,
      "Posted 5 hours ago",
    ),
  ];

  final List<SellerTaskModel> _sellerRecommendedTasks = [
    SellerTaskModel("Figma UI Design for E-commerce App", "\$150", [
      "UI/UX",
      "Figma",
    ], "Due in: 2 hours"),
    SellerTaskModel("Write Python automation script", "\$80", [
      "Python",
      "Automation",
    ], "Due in: 5 hours"),
    SellerTaskModel("Edit 3 short form videos for TikTok", "\$60", [
      "Video Editing",
      "Premiere",
    ], "Due in: 1 day"),
  ];

  String get selectedCategory => _selectedCategory;

  List<TaskModel> get filteredTasks {
    if (_selectedCategory == "All") {
      return _allTasks;
    }
    return _allTasks.where((task) => task.category == _selectedCategory).toList();
  }
  
  List<SellerTaskModel> get sellerRecommendedTasks => _sellerRecommendedTasks;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
