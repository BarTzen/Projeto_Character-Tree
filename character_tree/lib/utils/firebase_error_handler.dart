import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseErrorHandler {
  static String getLocalizedMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Conta não encontrada para este email';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Este email já está sendo usado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'user-disabled':
        return 'Esta conta foi desativada';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      case 'account-exists-with-different-credential':
        return 'Conta já existe com outras credenciais';
      case 'requires-recent-login':
        return 'Por favor, faça login novamente para continuar';
      case 'provider-already-linked':
        return 'Esta conta já está vinculada a outro provedor';
      case 'credential-already-in-use':
        return 'Esta credencial já está em uso por outra conta';
      default:
        return 'Erro: ${error.message ?? "Erro desconhecido"}';
    }
  }

  static void handleError(BuildContext context, dynamic error) {
    if (error is FirebaseAuthException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalizedMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<T?> handleFutureError<T>(
    BuildContext context,
    Future<T> future,
  ) async {
    try {
      return await future;
    } catch (error) {
      handleError(context, error);
      return null;
    }
  }
}
