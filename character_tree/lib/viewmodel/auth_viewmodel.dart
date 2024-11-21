import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/firestore_service.dart';

/// Logger para a classe AuthViewModel
final _log = Logger('AuthViewModel');

/// Estados possíveis de autenticação
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// ViewModel responsável por gerenciar o estado de autenticação do usuário
class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  final CacheService _cacheService;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Campos do formulário
  String _email = '';
  String _password = '';
  String _name = '';
  bool _isPasswordVisible = false;

  // Erros de validação
  String? _emailError;
  String? _passwordError;
  String? _nameError;

  AuthViewModel({
    required AuthService authService,
    required CacheService cacheService,
  })  : _authService = authService,
        _cacheService = cacheService {
    _initializeAuth();
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _currentUser != null && _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  String get email => _email;
  String get password => _password;
  String get name => _name;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get nameError => _nameError;

  // Setters com validação
  void setEmail(String value) {
    _email = value;
    _emailError = _validateEmail(value);
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _validatePassword(value);
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    _nameError = _validateName(value);
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Validações
  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email é obrigatório';
    if (!value.contains('@')) return 'Email inválido';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Senha deve ter no mínimo 6 caracteres';
    return null;
  }

  String? _validateName(String value) {
    if (value.isEmpty) return 'Nome é obrigatório';
    if (value.length < 3) return 'Nome deve ter no mínimo 3 caracteres';
    return null;
  }

  // Método para registro com email
  Future<void> registerWithEmail(
      String email, String password, String name) async {
    return signUpWithEmail(email, password, name);
  }

  // Limpar dados do formulário
  void clearForm() {
    _email = '';
    _password = '';
    _name = '';
    _emailError = null;
    _passwordError = null;
    _nameError = null;
    _isPasswordVisible = false;
    notifyListeners();
  }

  /// Inicializa o estado de autenticação verificando cache e estado atual
  Future<void> _initializeAuth() async {
    _log.info('Iniciando autenticação');
    _setStatus(AuthStatus.loading);
    try {
      // Tenta recuperar usuário do cache primeiro
      _currentUser = _cacheService.getCachedUser();
      if (_currentUser != null) {
        _setStatus(AuthStatus.authenticated);
      }

      // Verifica autenticação atual
      final user = await _authService.getCurrentUser();
      if (user != null) {
        await _handleSuccessfulAuth(user);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _log.severe('Falha na inicialização da autenticação', e);
      _handleError('Erro ao inicializar autenticação', e);
    }
  }

  /// Realiza login com email e senha
  Future<void> signInWithEmail(String email, String password) async {
    _log.info('Tentando login com email: $email');
    await _performAuthAction(() async {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        await _handleSuccessfulAuth(user);
      } else {
        throw Exception('Falha no login');
      }
    });
  }

  /// Realiza registro de novo usuário com email e senha
  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    if (!UserModel.isValidEmail(email)) {
      _handleError('Validação', 'Email inválido');
      return;
    }
    if (password.length < 6) {
      _handleError('Validação', 'A senha deve ter pelo menos 6 caracteres');
      return;
    }
    if (name.trim().isEmpty) {
      _handleError('Validação', 'O nome não pode estar vazio');
      return;
    }
    _log.info('Tentando registro com email: $email');
    await _performAuthAction(() async {
      final user = await _authService.signUpWithEmail(email, password, name);
      if (user != null) {
        await _handleSuccessfulAuth(user);
      } else {
        throw Exception('Falha no registro');
      }
    });
  }

  /// Realiza autenticação usando conta Google
  Future<void> signInWithGoogle() async {
    _log.info('Iniciando autenticação com Google');
    await _performAuthAction(() async {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _handleSuccessfulAuth(user);
      } else {
        throw Exception('Falha no login com Google');
      }
    });
  }

  /// Realiza logout do usuário
  Future<void> signOut() async {
    _log.info('Realizando logout');
    try {
      // Primeiro, atualizar o status para loading
      _setStatus(AuthStatus.loading);

      // Limpar o estado do usuário atual imediatamente
      _currentUser = null;

      // Notificar os ouvintes da mudança
      notifyListeners();

      // Realizar as operações de logout
      await Future.wait([
        _authService.signOut(),
        _cacheService.clearCache(),
      ]);

      // Limpar dados do formulário
      clearForm();

      // Definir status como desautenticado
      _setStatus(AuthStatus.unauthenticated);

      // Garantir que todas as alterações foram propagadas
      await Future.microtask(() {});
    } catch (e) {
      _log.severe('Erro ao realizar logout', e);
      _handleError('Falha ao realizar logout', e);
      rethrow; // Propagar o erro para ser tratado na UI
    }
  }

  /// Atualiza informações do perfil do usuário
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    _log.info('Atualizando perfil do usuário');
    await _performAuthAction(() async {
      await _authService.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      // Atualizar usuário atual
      final updatedUser = await _authService.getCurrentUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _cacheService.cacheUserData(updatedUser);
        notifyListeners();
      }
    });
  }

  // Reset de senha
  Future<void> resetPassword(String email) async {
    await _performAuthAction(() async {
      await _authService.resetPassword(email);
    });
  }

  // Exclusão de conta
  Future<void> deleteAccount(String password) async {
    await _performAuthAction(() async {
      await _authService.deleteAccount(password);
      await _cacheService.clearCache();
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
    });
  }

  /// Funções auxiliares
  Future<void> _performAuthAction(Future<void> Function() action) async {
    _setStatus(AuthStatus.loading);
    try {
      await action().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('A operação excedeu o tempo limite');
        },
      );
      _errorMessage = null;
      _log.fine('Operação de autenticação concluída com sucesso');
    } on TimeoutException {
      _handleError('Timeout', 'A operação demorou muito para responder');
    } catch (e) {
      _log.severe('Falha na operação de autenticação', e);
      _handleError('Erro na operação de autenticação', e);
    }
  }

  Future<void> _handleSuccessfulAuth(UserModel user) async {
    _log.info('Autenticação bem-sucedida para usuário: ${user.email}');
    _currentUser = user;
    await _cacheService.cacheUserData(user);
    _authService.startTokenRefresh();
    _setStatus(AuthStatus.authenticated);
  }

  void _handleError(String message, dynamic error) {
    _log.severe(message, error);
    _errorMessage = _getErrorMessage(error);
    _setStatus(AuthStatus.error);
    debugPrint('$message: $error');
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
        case 'email-already-in-use':
          return 'Email já está em uso';
        case 'invalid-email':
          return 'Email inválido';
        case 'weak-password':
          return 'Senha muito fraca';
        case 'network-request-failed':
          return 'Erro de conexão';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde';
        case 'operation-not-allowed':
          return 'Operação não permitida';
        case 'requires-recent-login':
          return 'Por favor, faça login novamente para continuar';
        default:
          return 'Erro de autenticação: ${error.message}';
      }
    } else if (error is FirestoreException) {
      return error.message;
    }
    return error.toString();
  }

  @override
  void dispose() {
    _log.info('Disposing AuthViewModel');
    _authService.stopTokenRefresh();
    super.dispose();
  }
}
