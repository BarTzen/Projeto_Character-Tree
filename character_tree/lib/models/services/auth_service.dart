// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _logger = Logger('AuthService');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtém o usuário atual
  User? get usuarioAtual => _auth.currentUser;

  // Método para login com email e senha
  Future<UserCredential> loginComEmailESenha(
      String email, String password) async {
    try {
      _logger.info('Tentando login com email: $email');
      final resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('Login realizado com sucesso');
      return resultado;
    } catch (e, stackTrace) {
      _logger.severe('Erro durante login com email e senha', e, stackTrace);
      rethrow;
    }
  }

  // Método para registro com email e senha
  Future<UserCredential> criarContaComEmailESenha(
      String email, String password) async {
    try {
      _logger.info('Tentando registrar novo usuário com email: $email');
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('Registro realizado com sucesso');
      return resultado;
    } catch (e, stackTrace) {
      _logger.severe('Erro durante registro com email e senha', e, stackTrace);
      rethrow;
    }
  }

  // Método para login com Google
  Future<UserCredential> loginComGoogle() async {
    try {
      _logger.info('Iniciando processo de login com Google');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login com Google cancelado pelo usuário');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final resultado = await _auth.signInWithCredential(credential);
      _logger.info('Login com Google realizado com sucesso');
      return resultado;
    } catch (e, stackTrace) {
      _logger.severe('Erro durante login com Google', e, stackTrace);
      rethrow;
    }
  }

  // Método para redefinição de senha
  Future<void> redefinirSenha(String email) async {
    try {
      _logger.info('Enviando email de redefinição de senha para: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Email de redefinição enviado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro ao enviar email de redefinição', e, stackTrace);
      rethrow;
    }
  }

  // Método para logout
  Future<void> sair() async {
    try {
      _logger.info('Iniciando processo de logout');
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.info('Logout realizado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro durante logout', e, stackTrace);
      rethrow;
    }
  }

  // Método para atualizar perfil do usuário
  Future<void> atualizarPerfilUsuario(
      {String? displayName, String? photoURL}) async {
    try {
      _logger.info('Atualizando perfil do usuário');
      await _auth.currentUser!
          .updateProfile(displayName: displayName, photoURL: photoURL);
      _logger.info('Perfil do usuário atualizado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro ao atualizar perfil do usuário', e, stackTrace);
      rethrow;
    }
  }

  // Método para obter dados do usuário
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      return doc.data();
    } catch (e, stackTrace) {
      _logger.severe('Erro ao obter dados do usuário', e, stackTrace);
      rethrow;
    }
  }

  // Stream para monitorar mudanças no estado de autenticação
  Stream<User?> get estadoDeAutenticacao => _auth.authStateChanges();
}
