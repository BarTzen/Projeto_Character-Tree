import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/character_model.dart';

class CharacterViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final String treeId;
  final List<CharacterModel> _characters = [];
  bool _isLoading = false; // removido final para permitir alteração
  String? _error;

  CharacterViewModel(
      {required FirestoreService firestoreService, required this.treeId})
      : _firestoreService = firestoreService {
    loadCharacters();
  }

  List<CharacterModel> get characters => _characters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCharacters() async {
    try {
      _isLoading = true;
      notifyListeners();

      final characters = await _firestoreService.getCharacters(treeId);
      _characters.clear();
      _characters.addAll(characters);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar personagens: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCharacter(
      String treeId, String name, String? description) async {
    try {
      _isLoading = true;
      notifyListeners();

      final character = CharacterModel(
        id: DateTime.now().toString(),
        name: name,
        description: description,
        treeId: treeId,
        createdAt: DateTime.now(),
        lastEdited: DateTime.now(),
        position: {'x': 0, 'y': 0}, // corrigido de 'dx' para 'x'
        connectedCharacters: [],
      );

      await _firestoreService.addCharacter(character);
      await loadCharacters();
    } catch (e) {
      _error = 'Erro ao adicionar personagem: $e';
      notifyListeners();
    }
  }

  Future<void> updateCharacterPosition(CharacterModel character) async {
    try {
      await _firestoreService.updateCharacter(character);
      await loadCharacters();
    } catch (e) {
      _error = 'Erro ao atualizar posição: $e';
      notifyListeners();
    }
  }

  Future<void> connectCharacters(String parentId, String childId,
      {String? connectionType}) async {
    try {
      await _firestoreService.connectCharacters(
        treeId,
        parentId,
        childId,
        connectionType: connectionType,
      );
      await loadCharacters();
    } catch (e) {
      _error = 'Erro ao conectar personagens: $e';
      notifyListeners();
    }
  }

  Future<void> disconnectCharacters(String sourceId, String targetId) async {
    try {
      await _firestoreService.disconnectCharacters(sourceId, targetId, treeId);
      await loadCharacters();
    } catch (e) {
      _error = 'Erro ao desconectar personagens: $e';
      notifyListeners();
    }
  }
}
