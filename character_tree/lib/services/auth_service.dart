import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();
  final Logger _logger = Logger('AuthService');

  AuthService() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        debugPrint(
            '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
      }
    });
  }

  /// Retorna o usuário autenticado atualmente
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Buscar dados adicionais do Firestore
      final userData = await _firestoreService.fetchUserById(user.uid);
      if (userData != null) {
        return userData;
      }

      // Se não encontrar no Firestore, criar novo modelo
      return UserModel(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        avatarUrl: user.photoURL,
        avatarColor: UserModel.generateAvatarColor(user.email ?? ''),
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLogin: user.metadata.lastSignInTime ?? DateTime.now(),
      );
    }
    return null;
  }

  /// Cria um UserModel a partir de um User do Firebase
  UserModel _createUserModel(User user, {String? customName}) {
    return UserModel(
      id: user.uid,
      name: customName ?? user.displayName ?? '',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      avatarColor: UserModel.generateAvatarColor(user.email ?? ''),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLogin: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Realiza login com email e senha.
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Buscar dados existentes do Firestore
        final storedUser = await _firestoreService.fetchUserById(user.uid);
        if (storedUser != null) {
          // Atualizar apenas o lastLogin
          final updatedUser = storedUser.copyWith(
            lastLogin: DateTime.now(),
          );
          await _firestoreService.updateLastLogin(user.uid);
          return updatedUser;
        }

        // Se não existir no Firestore, criar novo
        final newUser = _createUserModel(user);
        await _firestoreService.saveUser(newUser);
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      _logger.severe('Erro de autenticação: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.severe('Erro ao realizar login com email e senha.', e);
      rethrow;
    }
    return null;
  }

  /// Registra um novo usuário com email e senha.
  Future<UserModel?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Atualizar o displayName no Firebase Auth
        await user.updateDisplayName(name);

        final userModel = _createUserModel(user, customName: name);
        await _firestoreService.saveUser(userModel);
        return userModel;
      }
    } catch (e) {
      _logger.severe('Erro ao registrar usuário com email e senha.', e);
      rethrow;
    }
    return null;
  }

  /// Realiza login com o Google.
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Verificar se já existe uma sessão ativa
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.warning('Login com Google cancelado pelo usuário.');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Verificar se usuário já existe
        final existingUser = await _firestoreService.fetchUserById(user.uid);
        if (existingUser != null) {
          final updatedUser = existingUser.copyWith(
            lastLogin: DateTime.now(),
            avatarUrl: user.photoURL,
          );
          await _firestoreService.saveUser(updatedUser);
          return updatedUser;
        }

        // Criar novo usuário
        final userModel = _createUserModel(user);
        await _firestoreService.saveUser(userModel);
        return userModel;
      }
    } catch (e) {
      _logger.severe('Erro ao realizar login com Google.', e);
      // Garantir que qualquer sessão parcial seja limpa
      await _googleSignIn.signOut();
      rethrow;
    }
    return null;
  }

  /// Desloga o usuário atual.
  Future<void> signOut() async {
    try {
      // Verificar se existe login do Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      _logger.info('Logout realizado com sucesso.');
    } catch (e) {
      _logger.severe('Erro ao realizar logout.', e);
      rethrow;
    }
  }

  /// Exclui a conta do usuário atual.
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-autenticar o usuário antes de operações sensíveis
        final credentials = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credentials);

        // Primeiro exclui os dados do Firestore
        await _firestoreService.deleteUserData(user.uid);

        // Depois exclui a conta
        await user.delete();

        // Realizar logout após exclusão
        await signOut();

        _logger.info('Conta do usuário excluída com sucesso: ${user.uid}');
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não está autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      _logger.severe('Erro de autenticação ao excluir conta: ${e.code}');
      rethrow;
    } catch (e) {
      _logger.severe('Erro ao excluir a conta do usuário.', e);
      rethrow;
    }
  }

  // Atualizar perfil do usuário
  Future<void> updateUserProfile({String? name, String? avatarUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final updates = <Future>[];

        if (name != null) {
          updates.add(user.updateDisplayName(name));
        }
        if (avatarUrl != null) {
          updates.add(user.updatePhotoURL(avatarUrl));
        }

        await Future.wait(updates);

        // Atualiza no Firestore
        if (name != null || avatarUrl != null) {
          await _firestoreService.updateUser(user.uid, {
            if (name != null) 'name': name,
            if (avatarUrl != null) 'avatarUrl': avatarUrl,
            'updatedAt': DateTime.now(),
          });
        }

        _logger.info('Perfil do usuário atualizado com sucesso.');
      } else {
        throw Exception('Usuário não está autenticado');
      }
    } catch (e) {
      _logger.severe('Erro ao atualizar perfil do usuário.', e);
      rethrow;
    }
  }

  // Redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('E-mail de redefinição de senha enviado para $email.');
    } catch (e) {
      _logger.severe('Erro ao enviar e-mail de redefinição de senha.', e);
      rethrow;
    }
  }

  // Enviar e-mail de verificação
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _logger.info('E-mail de verificação enviado para ${user.email}.');
      } else {
        _logger
            .warning('Usuário já verificou o e-mail ou não está autenticado.');
      }
    } catch (e) {
      _logger.severe('Erro ao enviar e-mail de verificação.', e);
      rethrow;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult(true);
        _logger.info('Token atualizado com sucesso');
        return idTokenResult.token; // Retorna o token para uso posterior
      }
      return null;
    } catch (e) {
      _logger.severe('Erro ao atualizar token', e);
      rethrow;
    }
  }

  Timer? _refreshTimer;

  void startTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 45),
      (_) => refreshToken(),
    );
  }

  void stopTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
