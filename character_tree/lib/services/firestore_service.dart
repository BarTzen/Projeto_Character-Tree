import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/tree_model.dart';
import '../models/character_model.dart';
import '../models/relationship_type.dart'; // Adicionar importação

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('FirestoreService');
  static bool _isLoggerInitialized = false;

  // Definir constantes para nomes de coleções e campos
  static const String collectionArvores = 'arvores';
  static const String collectionPersonagens = 'personagens';

  FirestoreService() {
    // Configura o logger apenas em modo debug e evita duplicação
    if (kDebugMode && !_isLoggerInitialized) {
      Logger.root.level = Level.INFO; // Ajustado para INFO para reduzir ruído
      Logger.root.onRecord.listen((record) {
        // Simplifica o formato do log
        debugPrint('[${record.level.name}] ${record.message}');
      });
      _isLoggerInitialized = true;
    }
  }

  /// Trata e registra erros de forma padronizada
  void _handleError(String operation, dynamic error, String id) {
    final message = 'Erro ao $operation (ID: $id)';
    if (error is FirebaseException) {
      _logger.severe('$message: ${error.message}');
      throw FirestoreException('Erro do Firestore: ${error.message}');
    }
    _logger.severe(message);
    throw FirestoreException(message);
  }

  Future<T?> _withTimeout<T>(
      Future<T?> Function() operation, String operationName) async {
    try {
      return await operation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
              'Operação $operationName excedeu o tempo limite');
        },
      );
    } on TimeoutException catch (e) {
      _logger.severe('Timeout: $operationName', e);
      rethrow;
    } catch (e) {
      _handleError(operationName, e, 'timeout');
      return null;
    }
  }

  /// Método utilitário para log de sucesso
  void _logSuccess(String operation, String id) {
    _logger.info('$operation concluído: $id');
  }

  // ========================= MÉTODOS DE USUÁRIO =========================

  /// Salva ou atualiza um usuário no Firestore.
  Future<void> saveUser(UserModel user) async {
    try {
      // Validar dados antes de salvar
      user.validate();
      await _firestore.collection('usuarios').doc(user.id).set(user.toMap());
      _logSuccess('Salvar usuário', user.id);
    } catch (e) {
      _handleError('salvar usuário', e, user.id);
    }
  }

  /// Busca um usuário pelo ID.
  Future<UserModel?> fetchUserById(String userId) async {
    return _withTimeout(() async {
      final doc = await _firestore.collection('usuarios').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    }, 'buscar usuário');
  }

  /// Atualiza o último login do usuário.
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
      _logSuccess('Atualizar último login', userId);
    } catch (e) {
      _handleError('atualizar último login', e, userId);
    }
  }

  /// Atualiza dados específicos do usuário
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.info('Dados do usuário atualizados: $userId');
    } catch (e) {
      _handleError('atualizar usuário', e, userId);
    }
  }

  /// Deleta todos os dados do usuário
  Future<void> deleteUserData(String userId) async {
    try {
      // Usar batch para garantir atomicidade
      WriteBatch batch = _firestore.batch();

      // Deletar árvores do usuário
      final trees = await _firestore
          .collection('arvores')
          .where('userId', isEqualTo: userId)
          .get();

      for (var tree in trees.docs) {
        // Deletar personagens da árvore
        final characters = await _firestore
            .collection('personagens')
            .where('treeId', isEqualTo: tree.id)
            .get();

        for (var character in characters.docs) {
          batch.delete(character.reference);
        }

        batch.delete(tree.reference);
      }

      // Deletar o documento do usuário
      batch.delete(_firestore.collection('usuarios').doc(userId));

      await batch.commit();
      _logger.info('Dados do usuário deletados com sucesso: $userId');
    } catch (e) {
      _handleError('deletar dados do usuário', e, userId);
    }
  }

  // ========================= MÉTODOS DE ÁRVORES =========================

  /// Cria uma nova árvore no Firestore
  Future<void> criarArvore(TreeModel tree) async {
    try {
      await _firestore
          .collection(collectionArvores)
          .doc(tree.id)
          .set(tree.toMap());
    } catch (e) {
      throw FirestoreException('Erro ao criar árvore: $e');
    }
  }

  /// Busca uma árvore pelo ID.
  Future<TreeModel?> buscarArvorePorId(String treeId) async {
    try {
      final doc = await _firestore.collection('arvores').doc(treeId).get();
      if (doc.exists) {
        _logger.info('Árvore encontrada: $treeId');
        return TreeModel.fromMap(doc.data()!);
      }
      _logger.warning('Árvore não encontrada: $treeId');
      return null;
    } catch (e) {
      _logger.severe('Erro ao buscar a árvore: $treeId', e);
      rethrow; // Substituir 'throw' por 'rethrow'
    }
  }

  /// Busca todas as árvores de um usuário com paginação
  Future<List<TreeModel>> fetchUserTrees(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      // Simplify the query to avoid complex index requirements
      var query = _firestore
          .collection('arvores')
          .where('userId', isEqualTo: userId)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final result = await query.get();

      final List<TreeModel> trees = [];
      for (var doc in result.docs) {
        try {
          final data = doc.data();
          // Ensure all required fields exist
          if (data.containsKey('id') &&
              data.containsKey('name') &&
              data.containsKey('createdAt') &&
              data.containsKey('lastEdited')) {
            final tree = TreeModel.fromMap(data);
            tree.docSnapshot = doc;
            trees.add(tree);
          } else {
            _logger
                .warning('Tree document ${doc.id} is missing required fields');
          }
        } catch (e) {
          _logger.warning('Error parsing tree document ${doc.id}: $e');
          continue;
        }
      }

      _logger.info('Loaded ${trees.length} trees for user: $userId');
      return trees;
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' &&
          e.message?.contains('index') == true) {
        _logger.warning('Index issue detected, using alternative query');
        // Fallback to a simpler query
        final snapshot = await _firestore
            .collection('arvores')
            .where('userId', isEqualTo: userId)
            .get();

        return snapshot.docs
            .map((doc) => TreeModel.fromMap(doc.data()))
            .toList();
      }
      rethrow;
    } catch (e) {
      _logger.severe('Error fetching trees for user $userId', e);
      rethrow;
    }
  }

  /// Atualiza o nome e a última edição da árvore.
  Future<void> updateTree(String treeId, String newName) async {
    try {
      await _firestore.collection('arvores').doc(treeId).update({
        'name': newName,
        'lastEdited': DateTime.now().toIso8601String(),
      });
      _logger.info('Árvore atualizada com sucesso: $treeId');
    } catch (e) {
      _logger.severe('Erro ao atualizar a árvore: $treeId', e);
      rethrow;
    }
  }

  /// Exclui uma árvore pelo ID.
  Future<void> deleteTree(String treeId) async {
    try {
      await _firestore.collection('arvores').doc(treeId).delete();
      _logger.info('Árvore excluída com sucesso: $treeId');
    } catch (e) {
      _logger.severe('Erro ao excluir a árvore: $treeId', e);
      rethrow;
    }
  }

  // ========================= MÉTODOS DE PERSONAGENS =========================

  // Remover método duplicado criarPersonagem e usar apenas createCharacter
  Future<void> createCharacter(CharacterModel character) async {
    try {
      if (character.treeId.isEmpty) {
        throw FirestoreException('TreeId não pode estar vazio');
      }

      final batch = _firestore.batch();
      final charRef = _firestore
          .collection(collectionArvores)
          .doc(character.treeId)
          .collection(collectionPersonagens)
          .doc(character.id);

      batch.set(charRef, character.toMap());
      batch.update(
          _firestore.collection(collectionArvores).doc(character.treeId), {
        'characterCount': FieldValue.increment(1),
        'lastEdited': DateTime.now().toIso8601String(),
      });

      await batch.commit();
      _logger.info('Personagem criado com sucesso: ${character.id}');
    } catch (e) {
      _handleError('criar personagem', e, character.id);
    }
  }

  /// Busca todos os personagens de uma árvore com paginação
  Future<List<CharacterModel>> buscarPersonagens(
    String treeId, {
    int limit = 50,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      if (treeId.isEmpty) {
        throw FirestoreException('TreeId não pode estar vazio');
      }

      var query = _firestore
          .collection('arvores')
          .doc(treeId)
          .collection('personagens')
          .orderBy('lastEdited', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final result = await _withTimeout(
        () => query.get(),
        'buscar personagens da árvore',
      );

      if (result == null) return [];

      final characters =
          result.docs.map((doc) => CharacterModel.fromMap(doc.data())).toList();

      _logger.info(
          '${characters.length} personagens encontrados para árvore: $treeId');
      return characters;
    } catch (e) {
      _logger.severe('Erro ao buscar personagens para a árvore: $treeId', e);
      rethrow;
    }
  }

  /// Atualiza os detalhes de um personagem.
  Future<void> atualizarPersonagem(CharacterModel character) async {
    try {
      await _firestore
          .collection('arvores')
          .doc(character.treeId)
          .collection('personagens')
          .doc(character.id)
          .update(character.toMap());
      _logger.info('Personagem atualizado com sucesso: ${character.id}');
    } catch (e) {
      _logger.severe('Erro ao atualizar o personagem: ${character.id}', e);
      rethrow;
    }
  }

  /// Exclui um personagem pelo ID e atualiza a contagem na árvore.
  Future<void> excluirPersonagem(String treeId, String characterId) async {
    try {
      await _firestore
          .collection('arvores')
          .doc(treeId)
          .collection('personagens')
          .doc(characterId)
          .delete();
      _logger.info('Personagem excluído com sucesso: $characterId');

      // Atualiza a contagem de personagens na árvore
      await _firestore.collection('arvores').doc(treeId).update({
        'characterCount': FieldValue.increment(-1),
      });
      _logger.info('Contagem de personagens atualizada para a árvore: $treeId');
    } catch (e) {
      _logger.severe('Erro ao excluir o personagem: $characterId', e);
      rethrow;
    }
  }

  Future<void> conectarPersonagens(
      String treeId, String sourceId, String targetId,
      {RelationType? relationType}) async {
    try {
      final batch = _firestore.batch();
      final sourceRef = _firestore
          .collection(collectionArvores)
          .doc(treeId)
          .collection(collectionPersonagens)
          .doc(sourceId);

      // Atualizar conexões e relacionamentos
      if (relationType != null) {
        batch.update(sourceRef, {
          'conexoes': FieldValue.arrayUnion([targetId]),
          'relacionamentos.$targetId': relationType.name,
        });
      } else {
        batch.update(sourceRef, {
          'conexoes': FieldValue.arrayUnion([targetId]),
        });
      }

      await batch.commit();
      _logger.info('Personagens conectados com sucesso');
    } catch (e) {
      _handleError('conectar personagens', e, '$sourceId-$targetId');
    }
  }

  Future<void> desconectarPersonagens(
    String treeId,
    String sourceId,
    String targetId,
  ) async {
    try {
      // Corrigir a referência da coleção
      final sourceRef = _firestore
          .collection(collectionArvores)
          .doc(treeId)
          .collection(collectionPersonagens)
          .doc(sourceId);

      await sourceRef.update({
        'conexoes': FieldValue.arrayRemove([targetId]),
        'relacionamentos.$targetId': FieldValue.delete(),
      });

      _logger.info('Personagens desconectados com sucesso');
    } catch (e) {
      _handleError('desconectar personagens', e, '$sourceId-$targetId');
    }
  }

  Future<void> updateCharacter(
    String treeId,
    String characterId, {
    String? name,
    String? description,
    Map<String, dynamic>? position,
  }) async {
    try {
      if (treeId.isEmpty) {
        throw FirestoreException('TreeId não pode estar vazio');
      }

      final charDoc = _firestore
          .collection(collectionArvores)
          .doc(treeId)
          .collection(collectionPersonagens)
          .doc(characterId);

      final Map<String, dynamic> updates = {
        'lastEdited': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (position != null) updates['position'] = position;

      await charDoc.update(updates);
      _logger.info('Personagem atualizado com sucesso: $characterId');
    } catch (e) {
      _handleError('atualizar personagem', e, characterId);
    }
  }

  Future<List<CharacterModel>> getCharacters(String treeId) async {
    try {
      return await buscarPersonagens(treeId);
    } catch (e) {
      _logger.severe('Erro ao buscar personagens', e);
      rethrow;
    }
  }
}

/// Exceção personalizada para erros do Firestore
class FirestoreException implements Exception {
  final String message;
  FirestoreException(this.message);

  @override
  String toString() => message;
}
