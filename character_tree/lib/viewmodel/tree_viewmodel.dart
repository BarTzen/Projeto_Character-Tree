import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/tree_model.dart';

class TreeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<TreeModel> _trees = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedTreeId;

  TreeViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<TreeModel> get trees => _trees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedTreeId => _selectedTreeId;

  Future<void> loadUserTrees(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trees = await _firestoreService.fetchUserTrees(userId);
    } catch (e) {
      _error = 'Erro ao carregar árvores: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTree(String userId, String name) async {
    try {
      final tree = TreeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        characterCount: 0,
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
      );

      await _firestoreService.createTree(tree);
      _trees.add(tree);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar árvore: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteTree(String treeId) async {
    try {
      await _firestoreService.deleteTree(treeId);
      _trees.removeWhere((tree) => tree.id == treeId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar árvore: ${e.toString()}';
      notifyListeners();
    }
  }

  void selectTree(String? treeId) {
    _selectedTreeId = treeId;
    notifyListeners();
  }
}
