// login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
// Importe os serviços necessários, como AuthService, etc.

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

  Future<void> login(BuildContext context) async {
    if (!validateAll()) {
      _logger.warning('Tentativa de login com dados inválidos');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _logger.info('Iniciando processo de login para usuário: $_email');

      // Aqui você implementaria a lógica real de login
      // Por exemplo:
      // await AuthService.login(_email, _password);

      _logger.info('Login realizado com sucesso');
      MessageHandler.showMessage(context, 'Login realizado com sucesso!');

      // Se o login for bem-sucedido, navegue para a próxima tela
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante o login', e, stackTrace);
      MessageHandler.showMessage(
          context, 'Erro ao fazer login: ${e.toString()}',
          isError: true);
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

      // Implemente a lógica de login com Google aqui
      // Por exemplo:
      // await AuthService.signInWithGoogle();

      _logger.info('Login com Google realizado com sucesso');

      // Se o login for bem-sucedido, navegue para a próxima tela
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante login com Google', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!validateEmail()) {
      _logger.warning('Tentativa de redefinição de senha com email inválido');
      MessageHandler.showMessage(
          context, 'Por favor, insira um email válido para redefinir a senha.',
          isError: true);
      return;
    }

    try {
      _logger.info('Iniciando processo de redefinição de senha para: $_email');

      // Implemente a lógica de redefinição de senha aqui
      // Por exemplo:
      // await AuthService.resetPassword(_email);

      _logger.info('Email de redefinição enviado com sucesso');
      MessageHandler.showMessage(
          context, 'Um email de redefinição de senha foi enviado para $_email');
    } catch (e, stackTrace) {
      _logger.severe('Erro ao enviar email de redefinição', e, stackTrace);
      MessageHandler.showMessage(
          context, 'Erro ao redefinir a senha: ${e.toString()}',
          isError: true);
    }
  }
}
