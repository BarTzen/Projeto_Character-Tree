import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/tree_model.dart';
import '../models/character_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('FirestoreService');

  FirestoreService() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        debugPrint(
            '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
      }
    });
  }

  /// Trata e registra erros de forma padronizada
  void _handleError(String operation, dynamic error, String id) {
    _logger.severe('Erro durante $operation (ID: $id): ${error.toString()}');
    throw FirestoreException(
        'Ocorreu um erro ao executar: $operation. Por favor, tente novamente.');
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

  // ========================= MÉTODOS DE USUÁRIO =========================

  /// Salva ou atualiza um usuário no Firestore.
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      _logger.info('Usuário salvo com sucesso: ${user.id}');
    } catch (e) {
      _logger.severe('Erro ao salvar o usuário: ${user.id}', e);
      rethrow;
    }
  }

  /// Busca um usuário pelo ID.
  Future<UserModel?> fetchUserById(String userId) async {
    return _withTimeout(() async {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    }, 'buscar usuário');
  }

  /// Atualiza o último login do usuário.
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
      _logger.info('Último login atualizado para o usuário: $userId');
    } catch (e) {
      _logger.severe('Erro ao atualizar o último login: $userId', e);
      rethrow;
    }
  }

  /// Atualiza dados específicos do usuário
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
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
          .collection('trees')
          .where('userId', isEqualTo: userId)
          .get();

      for (var tree in trees.docs) {
        // Deletar personagens da árvore
        final characters = await _firestore
            .collection('characters')
            .where('treeId', isEqualTo: tree.id)
            .get();

        for (var character in characters.docs) {
          batch.delete(character.reference);
        }

        batch.delete(tree.reference);
      }

      // Deletar o documento do usuário
      batch.delete(_firestore.collection('users').doc(userId));

      await batch.commit();
      _logger.info('Dados do usuário deletados com sucesso: $userId');
    } catch (e) {
      _handleError('deletar dados do usuário', e, userId);
    }
  }

  // ========================= MÉTODOS DE ÁRVORES =========================

  /// Cria uma nova árvore genealógica.
  Future<void> createTree(TreeModel tree) async {
    try {
      await _firestore.collection('trees').doc(tree.id).set(tree.toMap());
      _logger.info('Árvore criada com sucesso: ${tree.id}');
    } catch (e) {
      _logger.severe('Erro ao criar a árvore: ${tree.id}', e);
      rethrow;
    }
  }

  /// Busca uma árvore pelo ID.
  Future<TreeModel?> fetchTreeById(String treeId) async {
    try {
      final doc = await _firestore.collection('trees').doc(treeId).get();
      if (doc.exists) {
        _logger.info('Árvore encontrada: $treeId');
        return TreeModel.fromMap(doc.data()!);
      }
      _logger.warning('Árvore não encontrada: $treeId');
      return null;
    } catch (e) {
      _logger.severe('Erro ao buscar a árvore: $treeId', e);
      rethrow;
    }
  }

  /// Busca todas as árvores de um usuário.
  Future<List<TreeModel>> fetchUserTrees(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('trees')
          .where('userId', isEqualTo: userId)
          .get();

      _logger.info('Árvores encontradas para o usuário: $userId');
      return querySnapshot.docs
          .map((doc) => TreeModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _logger.severe('Erro ao buscar as árvores para o usuário: $userId', e);
      rethrow;
    }
  }

  /// Atualiza o nome e a última edição da árvore.
  Future<void> updateTree(String treeId, String newName) async {
    try {
      await _firestore.collection('trees').doc(treeId).update({
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
      await _firestore.collection('trees').doc(treeId).delete();
      _logger.info('Árvore excluída com sucesso: $treeId');
    } catch (e) {
      _logger.severe('Erro ao excluir a árvore: $treeId', e);
      rethrow;
    }
  }

  // ========================= MÉTODOS DE PERSONAGENS =========================

  /// Cria um novo personagem.
  Future<void> createCharacter(CharacterModel character) async {
    try {
      await _firestore
          .collection('characters')
          .doc(character.id)
          .set(character.toMap());
      _logger.info('Personagem criado com sucesso: ${character.id}');
    } catch (e) {
      _logger.severe('Erro ao criar o personagem: ${character.id}', e);
      rethrow;
    }
  }

  /// Busca todos os personagens de uma árvore.
  Future<List<CharacterModel>> fetchTreeCharacters(String treeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('characters')
          .where('treeId', isEqualTo: treeId)
          .get();

      _logger.info('Personagens encontrados para a árvore: $treeId');
      return querySnapshot.docs
          .map((doc) => CharacterModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _logger.severe('Erro ao buscar os personagens para a árvore: $treeId', e);
      rethrow;
    }
  }

  /// Atualiza os dados de um personagem.
  Future<void> updateCharacter(CharacterModel character) async {
    try {
      await _firestore
          .collection('characters')
          .doc(character.id)
          .update(character.toMap());
      _logger.info('Personagem atualizado com sucesso: ${character.id}');
    } catch (e) {
      _logger.severe('Erro ao atualizar o personagem: ${character.id}', e);
      rethrow;
    }
  }

  /// Atualiza a posição de um personagem.
  Future<void> updateCharacterPosition(
      String characterId, double x, double y) async {
    try {
      await _firestore.collection('characters').doc(characterId).update({
        'position': {'x': x, 'y': y},
        'lastEdited': DateTime.now().toIso8601String(),
      });
      _logger.info('Posição do personagem atualizada: $characterId');
    } catch (e) {
      _logger.severe(
          'Erro ao atualizar a posição do personagem: $characterId', e);
      rethrow;
    }
  }

  /// Exclui um personagem pelo ID.
  Future<void> deleteCharacter(String characterId) async {
    try {
      await _firestore.collection('characters').doc(characterId).delete();
      _logger.info('Personagem excluído com sucesso: $characterId');
    } catch (e) {
      _logger.severe('Erro ao excluir o personagem: $characterId', e);
      rethrow;
    }
  }

  Future<List<CharacterModel>> getCharacters(String treeId) async {
    final snapshot = await _firestore
        .collection('characters')
        .where('treeId', isEqualTo: treeId)
        .get();
    return snapshot.docs
        .map((doc) => CharacterModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> addCharacter(CharacterModel character) async {
    await _firestore.collection('characters').add(character.toMap());
  }

  Future<void> connectCharacters(String treeId, String parentId, String childId,
      {String? connectionType}) async {
    try {
      _logger.info('Conectando personagens: parent=$parentId, child=$childId');

      final batch = _firestore.batch();
      final parentRef = _firestore
          .collection('trees')
          .doc(treeId)
          .collection('characters')
          .doc(parentId);
      final childRef = _firestore
          .collection('trees')
          .doc(treeId)
          .collection('characters')
          .doc(childId);

      // Update parent's children array
      batch.update(parentRef, {
        'children': FieldValue.arrayUnion([childId])
      });

      // Update child's parent field and connection type if provided
      Map<String, dynamic> childUpdate = {'parent': parentId};
      if (connectionType != null) {
        childUpdate['connectionType'] = connectionType;
      }
      batch.update(childRef, childUpdate);

      await batch.commit();
      _logger.info('Personagens conectados com sucesso');
    } catch (e) {
      _handleError('conectar personagens', e, '$parentId-$childId');
    }
  }

  Future<void> disconnectCharacters(
    String sourceId,
    String targetId,
    String treeId,
  ) async {
    try {
      final sourceDoc = _firestore.collection('characters').doc(sourceId);

      await sourceDoc.update({
        'connectedCharacters': FieldValue.arrayRemove([targetId]),
        'relationships.$targetId': FieldValue.delete(),
      });
    } catch (e) {
      _handleError('disconnectCharacters', e, '$sourceId-$targetId');
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
