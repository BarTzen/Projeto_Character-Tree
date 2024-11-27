import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../models/character_model.dart';
import '../models/relationship_type.dart';

class CharacterViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  String treeId;
  List<CharacterModel> _characters = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  final Box localCache; // Remover <dynamic>

  CharacterViewModel({
    required FirestoreService firestoreService,
    required this.treeId,
    required this.localCache,
  }) : _firestoreService = firestoreService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CharacterModel> get filteredCharacters => _searchQuery.isEmpty
      ? _characters
      : _characters
          .where((char) =>
              char.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (char.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();

  List<CharacterModel> get characters => _characters;

  Future<void> loadCharacters() async {
    if (treeId.isEmpty) {
      _error = 'ID da árvore não pode estar vazio';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Tenta carregar do cache primeiro
      final cachedData = localCache.get('characters_$treeId');
      if (cachedData != null) {
        _characters = List<Map<String, dynamic>>.from(cachedData)
            .map((map) => CharacterModel.fromMap(map))
            .toList();
        notifyListeners();
      }

      // Carrega dados do servidor
      final serverData = await _firestoreService.getCharacters(treeId);
      _characters = serverData;
      _error = null;

      // Atualiza o cache
      await localCache.put(
          'characters_$treeId', _characters.map((c) => c.toMap()).toList());
    } catch (e) {
      _error = 'Erro ao carregar personagens: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCharacter({
    required String name,
    String? description,
    required BuildContext context,
  }) async {
    CharacterModel? newCharacter; // Declare variable before try block
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final position = _calculateInitialPosition();

      newCharacter = CharacterModel(
        // Remove 'final' since it's declared above
        id: const Uuid().v4(),
        name: name,
        description: description,
        treeId: treeId,
        createdAt: now,
        lastEdited: now,
        position: position,
        connections: [],
        relationships: {},
      );

      // Primeiro adiciona à lista local
      _characters.add(newCharacter);
      notifyListeners();

      // Depois salva no Firestore
      await _firestoreService.createCharacter(newCharacter);

      _error = null;
    } catch (e) {
      _error = e.toString();
      // Remove da lista local se falhar o salvamento
      if (newCharacter != null) {
        _characters.removeWhere((c) => c.id == newCharacter?.id);
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, double> _calculateInitialPosition() {
    if (_characters.isEmpty) {
      return {'x': 500.0, 'y': 300.0};
    }

    // Encontra uma posição livre em uma grade
    double x = 500.0;
    double y = 300.0;
    bool positionFound = false;

    while (!positionFound) {
      positionFound = true;
      for (var char in _characters) {
        if ((char.position['x']! - x).abs() < 150 &&
            (char.position['y']! - y).abs() < 150) {
          positionFound = false;
          x += 150;
          if (x > 1500) {
            x = 500;
            y += 150;
          }
          break;
        }
      }
    }

    return {'x': x, 'y': y};
  }

  Future<void> updateCharacter(
    String characterId, {
    String? name,
    String? description,
    Map<String, double>? position,
  }) async {
    try {
      final character = _characters.firstWhere(
        (c) => c.id == characterId,
        orElse: () => throw Exception('Character not found'),
      );

      Map<String, double>? convertedPosition;
      if (position != null) {
        convertedPosition = {
          'x': position['x']?.toDouble() ?? 0.0,
          'y': position['y']?.toDouble() ?? 0.0,
        };
      }

      final updatedCharacter = character.copyWith(
        name: name,
        description: description,
        position: convertedPosition,
        lastEdited: DateTime.now(),
      );

      await _firestoreService.atualizarPersonagem(updatedCharacter);

      final index = _characters.indexOf(character);
      _characters[index] = updatedCharacter;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar personagem: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCharacter(String characterId) async {
    try {
      await _firestoreService.excluirPersonagem(treeId, characterId);
      _characters.removeWhere((c) => c.id == characterId);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao excluir personagem: $e';
      notifyListeners();
    }
  }

  Future<void> connectCharacters({
    required String sourceId,
    required String targetId,
    required String relationshipType,
  }) async {
    try {
      if (sourceId == targetId) {
        throw Exception('Não é possível conectar um personagem a ele mesmo');
      }

      final source = _characters.firstWhere((c) => c.id == sourceId);
      if (source.connections.contains(targetId)) {
        throw Exception('Personagens já estão conectados');
      }

      await _firestoreService.conectarPersonagens(
        treeId,
        sourceId,
        targetId,
        relationType: RelationType.values
            .byName(relationshipType), // Passa o tipo de relacionamento.
      );

      await loadCharacters();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao conectar personagens: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnectCharacters(String sourceId, String targetId) async {
    try {
      if (treeId.isEmpty) {
        throw Exception('TreeId não pode estar vazio');
      }

      await _firestoreService.desconectarPersonagens(
          treeId, sourceId, targetId);

      await loadCharacters();

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao desconectar personagens: $e';
      notifyListeners();
      rethrow;
    }
  }

  void updateTreeId(String newTreeId) {
    if (newTreeId.isEmpty) {
      _error = 'ID da árvore não pode estar vazio';
      notifyListeners();
      return;
    }

    // Limpa os dados anteriores antes de atualizar
    _characters = [];
    _error = null;
    treeId = newTreeId;

    // Carrega os novos dados
    loadCharacters();
  }

  Future<void> moveCharacter(
      CharacterModel character, double x, double y) async {
    try {
      // Verifica colisão antes de mover
      if (_checkCollision(x, y, excludeId: character.id)) {
        throw Exception(
            'Não é possível mover para esta posição: muito próximo de outro personagem');
      }

      // Garante que os valores sejam double
      final position = {
        'x': x.toDouble(),
        'y': y.toDouble(),
      };

      final updatedCharacter = character.copyWith(
        position: position,
      );

      await _firestoreService.updateCharacter(
        treeId,
        character.id,
        position: position,
      );

      final index = _characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _characters[index] = updatedCharacter;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao mover personagem: $e';
      notifyListeners();
      rethrow;
    }
  }

  bool _checkCollision(double x, double y, {String? excludeId}) {
    return _characters.any((char) =>
        char.id != excludeId &&
        (char.position['x']! - x).abs() < 150 &&
        (char.position['y']! - y).abs() < 150);
  }

  void searchCharacters(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // Adiciona método para tratamento de erros
  Future<void> handleAsyncOperation(Future<void> Function() operation) async {
    try {
      _isLoading = true;
      notifyListeners();
      await operation();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
