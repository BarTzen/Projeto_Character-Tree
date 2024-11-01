// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class FirestoreService {
  final _logger = Logger('FirestoreService');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para criar documento do usuário
  Future<void> criarDocumentoUsuario(
    String uid, {
    required String username,
    required String email,
  }) async {
    try {
      _logger.info('Criando documento para usuário: $email');
      await _firestore.collection('usuarios').doc(uid).set({
        'username': username,
        'email': email,
        'dataCriacao': FieldValue.serverTimestamp(),
        'ultimoLogin': FieldValue.serverTimestamp(),
      });
      _logger.info('Documento do usuário criado com sucesso');
    } catch (e, stackTrace) {
      _logger.severe('Erro ao criar documento do usuário', e, stackTrace);
      rethrow;
    }
  }

  // Método para atualizar último login com verificação de existência do documento
  Future<void> atualizarUltimoLogin(String uid,
      {String? username, String? email}) async {
    try {
      _logger.info('Atualizando último login para uid: $uid');
      final docRef = _firestore.collection('usuarios').doc(uid);

      // Verifica se o documento do usuário existe
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Atualiza o campo 'ultimoLogin' se o documento existir
        await docRef.update({
          'ultimoLogin': FieldValue.serverTimestamp(),
        });
        _logger.info('Último login atualizado com sucesso');
      } else if (username != null && email != null) {
        // Cria o documento se ele não existir e os dados de username e email foram fornecidos
        await criarDocumentoUsuario(uid, username: username, email: email);
      } else {
        _logger.warning(
            'Documento do usuário não encontrado e dados insuficientes para criá-lo');
      }
    } catch (e, stackTrace) {
      _logger.severe('Erro ao atualizar/criar último login', e, stackTrace);
      rethrow;
    }
  }

  // Método para obter dados do usuário
  Stream<DocumentSnapshot> getDadosUsuario(String uid) {
    _logger.info('Obtendo stream de dados do usuário: $uid');
    return _firestore.collection('usuarios').doc(uid).snapshots();
  }
}
