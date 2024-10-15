import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void login(String email, String password) {
    _isLoading = true;
    notifyListeners();

    // Simula um pequeno atraso (sem backend por enquanto)
    Future.delayed(Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}
