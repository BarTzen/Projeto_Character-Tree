// login_viewmodel.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../models/services/auth_service.dart';
import '../../models/services/firestore_service.dart';

// Utilitário para mensagens
class MessageHandler {
  static void showMessage(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}

class LoginViewModel extends ChangeNotifier {
  final _logger = Logger('LoginViewModel');
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);

  // Getters
  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  ValueNotifier<bool> get isPasswordVisible => _isPasswordVisible;

  // Setters
  void setEmail(String email) {
    _email = email;
    validateEmail();
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    validatePassword();
    notifyListeners();
  }

  // Validações
  bool validateEmail() {
    if (_email.isEmpty) {
      _emailError = 'Por favor, insira seu email';
      _logger.warning('Tentativa de validação com email vazio');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email)) {
      _emailError = 'Por favor, insira um email válido';
      _logger.warning('Email inválido fornecido: $_email');
    } else {
      _emailError = null;
      _logger.fine('Email validado com sucesso');
    }
    notifyListeners();
    return _emailError == null;
  }

  bool validatePassword() {
    if (_password.isEmpty) {
      _passwordError = 'Por favor, insira sua senha';
      _logger.warning('Tentativa de validação com senha vazia');
    } else if (_password.length < 6) {
      _passwordError = 'A senha deve ter pelo menos 6 caracteres';
      _logger.warning('Senha fornecida com menos de 6 caracteres');
    } else {
      _passwordError = null;
      _logger.fine('Senha validada com sucesso');
    }
    notifyListeners();
    return _passwordError == null;
  }

  bool validateAll() {
    final isValid = validateEmail() && validatePassword();
    _logger.info('Validação completa: ${isValid ? 'sucesso' : 'falha'}');
    return isValid;
  }

  // Ações
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
    _logger.fine('Visibilidade da senha alterada: ${_isPasswordVisible.value}');
    notifyListeners();
  }

  Future<void> login() async {
    if (!validateAll()) {
      _logger.warning('Tentativa de login com dados inválidos');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _logger.info('Iniciando processo de login para usuário: $_email');
      final userCredential =
          await _authService.loginComEmailESenha(_email, _password);
      await _firestoreService.atualizarUltimoLogin(userCredential.user!.uid);
      _logger.info('Login realizado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante o login', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _logger.info('Iniciando processo de login com Google');
      final userCredential = await _authService.loginComGoogle();
      await _firestoreService.atualizarUltimoLogin(userCredential.user!.uid);
      _logger.info('Login com Google realizado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante login com Google', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!validateEmail()) {
      _logger.warning('Tentativa de redefinição de senha com email inválido');
      return;
    }

    try {
      _logger.info('Iniciando processo de redefinição de senha para: $_email');
      await _authService.redefinirSenha(_email);
      _logger.info('Email de redefinição enviado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro ao enviar email de redefinição', e, stackTrace);
      rethrow;
    }
  }
}
