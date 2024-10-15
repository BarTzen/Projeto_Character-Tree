import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void register(
      String username, String email, String password, String confirmPassword) {
    _isLoading = true;
    notifyListeners();

    // Simula um pequeno atraso (sem backend por enquanto)
    Future.delayed(Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}
