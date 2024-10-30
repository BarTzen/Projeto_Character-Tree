// register_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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

class RegisterViewModel extends ChangeNotifier {
  final _logger = Logger('RegisterViewModel');

  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);

  // Getters
  bool get isLoading => _isLoading;
  String? get usernameError => _usernameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  ValueNotifier<bool> get isPasswordVisible => _isPasswordVisible;

  // Setters
  void setUsername(String username) {
    _username = username;
    validateUsername();
    notifyListeners();
  }

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

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    validateConfirmPassword();
    notifyListeners();
  }

  // Validações
  bool validateUsername() {
    if (_username.isEmpty) {
      _usernameError = 'Por favor, insira um nome de usuário';
      _logger.warning('Tentativa de validação com nome de usuário vazio');
    } else if (_username.length < 3) {
      _usernameError = 'O nome de usuário deve ter pelo menos 3 caracteres';
      _logger.warning('Nome de usuário muito curto: $_username');
    } else {
      _usernameError = null;
      _logger.fine('Nome de usuário validado com sucesso');
    }
    notifyListeners();
    return _usernameError == null;
  }

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
      _passwordError = 'Por favor, insira uma senha';
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

  bool validateConfirmPassword() {
    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Por favor, confirme sua senha';
      _logger.warning('Tentativa de validação com confirmação de senha vazia');
    } else if (_confirmPassword != _password) {
      _confirmPasswordError = 'As senhas não coincidem';
      _logger.warning('Senhas não coincidem');
    } else {
      _confirmPasswordError = null;
      _logger.fine('Confirmação de senha validada com sucesso');
    }
    notifyListeners();
    return _confirmPasswordError == null;
  }

  bool validateAll() {
    final isValid = validateUsername() &&
        validateEmail() &&
        validatePassword() &&
        validateConfirmPassword();
    _logger.info('Validação completa: ${isValid ? 'sucesso' : 'falha'}');
    return isValid;
  }

  // Ações
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
    _logger.fine('Visibilidade da senha alterada: ${_isPasswordVisible.value}');
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    if (!validateAll()) {
      _logger.warning('Tentativa de registro com dados inválidos');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _logger.info('Iniciando processo de registro para usuário: $_username');

      // Aqui você implementaria a lógica real de registro
      // Por exemplo:
      // await AuthService.register(_username, _email, _password);

      _logger.info('Registro realizado com sucesso');
      MessageHandler.showMessage(context, 'Registro realizado com sucesso!');

      // Navegue para a próxima tela
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante o registro', e, stackTrace);
      MessageHandler.showMessage(context, 'Erro ao registrar: ${e.toString()}',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      _logger.info('Iniciando processo de registro com Google');

      // Implemente a lógica de registro com Google aqui
      // Por exemplo:
      // await AuthService.signUpWithGoogle();

      _logger.info('Registro com Google realizado com sucesso');
      MessageHandler.showMessage(
          context, 'Registro com Google realizado com sucesso!');

      // Se o registro for bem-sucedido, navegue para a próxima tela
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante registro com Google', e, stackTrace);
      MessageHandler.showMessage(
          context, 'Erro ao registrar com Google: ${e.toString()}',
          isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}