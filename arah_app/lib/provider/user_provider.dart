import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider with ChangeNotifier {
  File? _profileImage;
  String _name = "Alex Johnson"; // Default mock user
  String _role = "Both"; // Buyer, Seller, Both
  String _experienceLevel = "Beginner";
  List<String> _skills = [];

  File? get profileImage => _profileImage;
  String get name => _name;
  String get role => _role;
  String get experienceLevel => _experienceLevel;
  List<String> get skills => _skills;

  final ImagePicker _picker = ImagePicker();

  UserProvider() {
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      _profileImage = File(imagePath);
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateRole(String role) {
    _role = role;
    notifyListeners();
  }

  void updateExperience(String level) {
    _experienceLevel = level;
    notifyListeners();
  }

  void toggleSkill(String skill) {
    if (_skills.contains(skill)) {
      _skills.remove(skill);
    } else {
      _skills.add(skill);
    }
    notifyListeners();
  }
}
