import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class RequestProvider with ChangeNotifier {
  String _budgetType = "Fixed Price";
  List<PlatformFile> _attachedFiles = [];

  String get budgetType => _budgetType;
  List<PlatformFile> get attachedFiles => _attachedFiles;

  void updateBudgetType(String type) {
    _budgetType = type;
    notifyListeners();
  }

  void addFiles(List<PlatformFile> files) {
    _attachedFiles.addAll(files);
    notifyListeners();
  }

  void removeFile(int index) {
    _attachedFiles.removeAt(index);
    notifyListeners();
  }
}
