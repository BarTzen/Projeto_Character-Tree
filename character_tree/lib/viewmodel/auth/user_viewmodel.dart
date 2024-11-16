import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../models/services/auth_service.dart';
import '../../models/services/firestore_service.dart';

class UserViewModel extends ChangeNotifier {
  final _logger = Logger('UserViewModel');
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _displayName;
  String? _email;
  String? _photoURL;

  // Getters
  String? get displayName => _displayName;
  String? get email => _email;
  String? get photoURL => _photoURL;

  // Método para carregar dados do usuário
  Future<void> loadUserData() async {
    try {
      final user = _authService.usuarioAtual;
      if (user != null) {
        _email = user.email;
        _displayName = user.displayName;
        _photoURL = user.photoURL;

        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          _displayName = userData['username'] ?? _displayName;
        }
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.severe('Erro ao carregar dados do usuário', e, stackTrace);
    }
  }
}
