import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/tree_model.dart';
import '../models/character_model.dart'; // Importar CharacterModel

/// ViewModel para gerenciamento de árvores genealógicas
class TreeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<TreeModel> _trees = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedTreeId;

  // Adicionar variáveis para paginação
  bool _hasMoreData = true;
  static const int _pageSize = 20;

  // Getters
  List<TreeModel> get trees => _trees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedTreeId => _selectedTreeId;
  bool get hasMoreData => _hasMoreData;

  TreeViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Carrega árvores do usuário especificado
  Future<void> loadUserTrees(String userId) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;

      // Simplify the query to avoid complex index requirements
      final trees = await _firestoreService.fetchUserTrees(userId);
      _trees = trees..sort((a, b) => b.lastEdited.compareTo(a.lastEdited));

      _hasMoreData = trees.length >= _pageSize;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _trees = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Cria uma nova árvore
  Future<void> createTree(String userId, String name) async {
    try {
      _setLoading(true);

      final tree = TreeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        characterCount: 0,
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
      );

      await _firestoreService.criarArvore(tree);
      _trees.add(tree);
      selectTree(tree.id);
    } catch (erro) {
      _error = 'Erro ao criar árvore: $erro';
    } finally {
      _setLoading(false);
    }
  }

  /// Exclui uma árvore
  Future<void> deleteTree(String treeId) async {
    try {
      await _firestoreService.deleteTree(treeId);
      _trees.removeWhere((tree) => tree.id == treeId);
      if (_selectedTreeId == treeId) {
        selectTree(null);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar árvore: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Seleciona uma árvore
  void selectTree(String? treeId) {
    _selectedTreeId = treeId;
    notifyListeners();
  }

  /// Atualiza dados da árvore
  Future<void> updateTree(String treeId, String name,
      {String? description}) async {
    if (name.trim().isEmpty) {
      throw Exception('O nome da árvore não pode estar vazio');
    }

    try {
      _setLoading(true);
      await _firestoreService.updateTree(treeId, name);

      final updatedTree = await _firestoreService.buscarArvorePorId(treeId);
      if (updatedTree != null) {
        final index = _trees.indexWhere((tree) => tree.id == treeId);
        if (index != -1) {
          _trees[index] = updatedTree;
        }
      }
      _error = null;
    } catch (e) {
      _error = 'Erro ao atualizar árvore: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Adicionar método para carregar mais árvores
  Future<void> loadMoreTrees(String userId) async {
    if (!_hasMoreData || _isLoading) return;

    try {
      _setLoading(true);
      final lastTree = _trees.isNotEmpty ? _trees.last : null;

      final newTrees = await _firestoreService.fetchUserTrees(
        userId,
        limit: _pageSize,
        lastDoc: lastTree?.docSnapshot,
      );

      _hasMoreData = newTrees.length >= _pageSize;
      if (newTrees.isNotEmpty) {
        _trees.addAll(newTrees);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao carregar mais árvores: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> atualizarPersonagemPosicao(CharacterModel character) async {
    try {
      await _firestoreService.updateCharacter(
        character.treeId,
        character.id,
        position: character.position,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar posição do personagem: $e';
      notifyListeners();
    }
  }

  /// Recarrega uma árvore específica
  Future<void> refreshTree(String treeId) async {
    try {
      final updatedTree = await _firestoreService.buscarArvorePorId(treeId);
      if (updatedTree != null) {
        final index = _trees.indexWhere((tree) => tree.id == treeId);
        if (index != -1) {
          _trees[index] = updatedTree;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Erro ao recarregar árvore: $e';
      notifyListeners();
    }
  }

  /// Adicionar método para carregar árvore específica
  Future<bool> loadSpecificTree(String treeId) async {
    try {
      _setLoading(true);
      final tree = await _firestoreService.buscarArvorePorId(treeId);
      if (tree != null) {
        final index = _trees.indexWhere((t) => t.id == treeId);
        if (index >= 0) {
          _trees[index] = tree;
        } else {
          _trees.add(tree);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erro ao carregar árvore: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
