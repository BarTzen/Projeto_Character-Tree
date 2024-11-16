import 'package:flutter/material.dart';

class GenealogyViewModel extends ChangeNotifier {
  // ...existing code...
  String genealogyName = '';
  String bookName = '';
  String mainCharacterName = '';
  String? imagePath;

  void setGenealogyName(String name) {
    genealogyName = name;
    notifyListeners();
  }

  void setBookName(String name) {
    bookName = name;
    notifyListeners();
  }

  void setMainCharacterName(String name) {
    mainCharacterName = name;
    notifyListeners();
  }

  void setImagePath(String path) {
    imagePath = path;
    notifyListeners();
  }

  void saveGenealogy() {
    // Logic to save genealogy
  }

  void cancelGenealogy() {
    // Logic to cancel genealogy creation
  }
}
