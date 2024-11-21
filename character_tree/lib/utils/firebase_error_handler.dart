import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseErrorHandler {
  static String getLocalizedMessage(
      BuildContext context, FirebaseAuthException error) {
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
      default:
        return 'Erro: ${error.message}';
    }
  }
}
