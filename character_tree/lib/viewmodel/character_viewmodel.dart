import 'dart:math';

import 'package:character_tree/utils/relation_type.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import '../services/firestore_service.dart';
import '../models/character_model.dart';

class CharacterViewModel extends ChangeNotifier {
  // Adicionar:
  // - Cache de renderização para grandes árvores
  // - Lazy loading para árvores muito grandes
  // - Otimização do cálculo de colisões

  final FirestoreService _firestoreService;
  final _log = Logger('CharacterViewModel');
  String treeId;
  List<CharacterModel> _characters = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  final Box localCache;

  CharacterModel? _selectedCharacter;
  CharacterModel? _connectionStart;
  Offset? _connectionEndPoint;

  // Getters para os novos estados
  CharacterModel? get selectedCharacter => _selectedCharacter;
  CharacterModel? get connectionStart => _connectionStart;
  Offset? get connectionEndPoint => _connectionEndPoint;

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

  /// Cache local com tempo de expiração
  Future<void> _updateCache() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await localCache.put('characters_${treeId}_timestamp', timestamp);
    await localCache.put(
      'characters_$treeId',
      _characters.map((c) => c.toMap()).toList(),
    );
  }

  /// Verifica se o cache está válido (menos de 1 hora)
  bool _isCacheValid() {
    final timestamp = localCache.get('characters_${treeId}_timestamp') as int?;
    if (timestamp == null) return false;
    final difference = DateTime.now().millisecondsSinceEpoch - timestamp;
    return difference < const Duration(hours: 1).inMilliseconds;
  }

  /// Carrega personagens com verificação de cache inteligente
  Future<void> loadCharacters() async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Iniciando carregamento de personagens');

      if (_isCacheValid()) {
        _loadFromCache();
        _log.info('Carregado do cache: ${_characters.length} personagens');
      }

      final serverData = await _firestoreService.getCharacters(treeId);
      _characters = serverData;
      _log.info('Carregado do servidor: ${_characters.length} personagens');

      await _updateCache();
      _error = null;
    } catch (e) {
      _log.severe('Erro ao carregar personagens', e);
      _error = 'Erro ao carregar personagens: $e';
      if (_characters.isEmpty && localCache.containsKey('characters_$treeId')) {
        _loadFromCache(); // Fallback para cache em caso de erro
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFromCache() {
    final cachedData = localCache.get('characters_$treeId');
    if (cachedData != null) {
      try {
        final List<dynamic> dataList = cachedData as List<dynamic>;
        _characters = dataList.map((item) {
          if (item is Map) {
            // Converter Map<dynamic, dynamic> para Map<String, dynamic>
            final Map<String, dynamic> stringMap = {};
            item.forEach((key, value) {
              if (key is String) {
                stringMap[key] = value;
              }
            });
            return CharacterModel.fromMap(stringMap);
          }
          throw Exception('Formato de cache inválido');
        }).toList();
        notifyListeners();
      } catch (e) {
        // Se houver erro na conversão, limpa o cache inválido
        localCache.delete('characters_$treeId');
        localCache.delete('characters_${treeId}_timestamp');
        _error = 'Erro ao carregar cache: $e';
      }
    }
  }

  // Métodos para controle e centralização
  Future<void> createCharacter({
    required String name,
    String? description,
    required BuildContext context,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Nome do personagem não pode estar vazio');
    }

    final newCharacter = CharacterModel(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description?.trim(),
      treeId: treeId,
      createdAt: DateTime.now(),
      lastEdited: DateTime.now(),
      position: _calculateInitialPosition(),
      connections: [],
      relationships: {},
    );

    await handleAsyncOperation(() async {
      _characters.add(newCharacter);
      await _firestoreService.createCharacter(newCharacter);
      await _updateCache();
    });
  }

  Map<String, double> _calculateInitialPosition() {
    if (_characters.isEmpty) {
      // Posição inicial no centro da viewport
      return {
        'x': canvasWidth / 2,
        'y': canvasHeight / 2,
      };
    }

    // Cálculo em grade com melhor distribuição
    double x = canvasWidth / 2;
    double y = canvasHeight / 2;
    bool positionFound = false;
    const double spacing = 250.0; // Aumentado o espaçamento entre cartões

    while (!positionFound) {
      positionFound = true;
      for (var char in _characters) {
        if ((char.position['x']! - x).abs() < spacing &&
            (char.position['y']! - y).abs() < spacing) {
          positionFound = false;
          x += spacing;
          if (x > canvasWidth - spacing) {
            x = spacing;
            y += spacing;
            if (y > canvasHeight - spacing) {
              y = spacing;
            }
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
    CharacterModel character,
    double x,
    double y,
  ) async {
    try {
      // Verifica colisão antes de mover
      if (_checkCollision(x, y, excludeId: character.id)) {
        throw Exception(
            'Não é possível mover para esta posição: muito próximo de outro personagem');
      }

      // Garanta que os valores sejam double
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

  /// Tratamento de operações assíncronas com retry
  Future<void> handleAsyncOperation(
    Future<void> Function() operation, {
    int retryCount = 3,
  }) async {
    int attempts = 0;
    while (attempts < retryCount) {
      try {
        _isLoading = true;
        notifyListeners();

        await operation();

        _error = null;
        break;
      } catch (e) {
        attempts++;
        if (attempts == retryCount) {
          _error = e.toString();
          throw Exception('Operação falhou após $retryCount tentativas: $e');
        }
        await Future.delayed(Duration(seconds: attempts));
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Seleciona um personagem no canvas
  void selectCharacter(CharacterModel? character) {
    _selectedCharacter = character;
    notifyListeners();
  }

  /// Inicia o processo de conexão entre personagens
  void startConnection(CharacterModel character) {
    _connectionStart = character;
    notifyListeners();
  }

  /// Atualiza o ponto final da conexão durante o arrasto
  void updateConnectionEndPoint(Offset? point) {
    _connectionEndPoint = point;
    notifyListeners();
  }

  /// Cancela o processo de conexão atual
  void cancelConnection() {
    _connectionStart = null;
    _connectionEndPoint = null;
    notifyListeners();
  }

  // Novo método para gerenciar zoom
  double _currentZoom = 1.0;
  double get currentZoom => _currentZoom;

  void updateZoom(double scale) {
    _currentZoom = scale.clamp(0.5, 2.0);
    notifyListeners();
  }

  // Método para gerenciar movimentação com validação
  Future<void> handleCharacterMove(
      CharacterModel character, Offset position) async {
    try {
      if (_checkCollision(position.dx, position.dy, excludeId: character.id)) {
        throw Exception('Posição ocupada por outro personagem');
      }
      await moveCharacter(character, position.dx, position.dy);
    } catch (e) {
      rethrow;
    }
  }

  // Método para gerenciar conexões com validação
  Future<void> handleCharacterConnection(
      String sourceId, String targetId, RelationType type) async {
    try {
      if (sourceId == targetId) {
        throw Exception('Não é possível conectar um personagem a ele mesmo');
      }
      await connectCharacters(
        sourceId: sourceId,
        targetId: targetId,
        relationshipType: type.name,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Constantes atualizadas do canvas
  static const double canvasWidth = 10000.0; // Aumentado para mais espaço
  static const double canvasHeight = 10000.0; // Aumentado para mais espaço
  static const double minScale = 0.1; // Permite mais zoom out
  static const double maxScale = 5.0; // Permite mais zoom in
  static const double zoomStep = 0.2;

  // Controle de transformação
  final TransformationController transformationController =
      TransformationController();

  void centerCanvas() {
    final Matrix4 matrix = Matrix4.identity()
      ..translate(canvasWidth / 4, canvasHeight / 4)
      ..scale(1.0); // Escala inicial mais adequada
    transformationController.value = matrix;
  }

  void handleZoom(double targetScale) {
    final scale = targetScale.clamp(minScale, maxScale);
    final centerPoint = Offset(canvasWidth / 2, canvasHeight / 2);

    final Matrix4 endMatrix = Matrix4.identity()
      ..translate(centerPoint.dx, centerPoint.dy)
      ..scale(scale)
      ..translate(-centerPoint.dx, -centerPoint.dy);

    transformationController.value = endMatrix;
    _currentZoom = scale;
    notifyListeners();
  }

  void zoomIn() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale < maxScale) {
      final newScale = (currentScale + zoomStep).clamp(minScale, maxScale);
      handleZoom(newScale);
    }
  }

  void zoomOut() {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale > minScale) {
      final newScale = (currentScale - zoomStep).clamp(minScale, maxScale);
      handleZoom(newScale);
    }
  }

  // Adicionar para controle do mini-mapa
  Rect? _visibleRect;
  Rect? get visibleRect => _visibleRect;

  void updateVisibleRect(Rect rect) {
    _visibleRect = rect;
    notifyListeners();
  }

  // Método para calcular o zoom necessário para mostrar todos os personagens
  void showAllCharacters() {
    if (_characters.isEmpty) return;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    // Encontra os limites do conteúdo
    for (var char in _characters) {
      final x = char.position['x']!;
      final y = char.position['y']!;
      minX = min(minX, x);
      minY = min(minY, y);
      maxX = max(maxX, x);
      maxY = max(maxY, y);
    }

    // Adiciona padding
    const padding = 100.0;
    minX -= padding;
    minY -= padding;
    maxX += padding;
    maxY += padding;

    // Calcula a matriz de transformação
    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;
    final scale = min(
      canvasWidth / contentWidth,
      canvasHeight / contentHeight,
    ).clamp(minScale, maxScale);

    final matrix = Matrix4.identity()
      ..translate(canvasWidth / 4, canvasHeight / 4)
      ..scale(scale);

    transformationController.value = matrix;
    notifyListeners();
  }

  // Adicionar estes métodos
  bool _isDragging = false;
  bool get isDragging => _isDragging;

  void setDragging(bool value) {
    _isDragging = value;
    notifyListeners();
  }

  bool _isInteracting = false;
  bool get isInteracting => _isInteracting;

  void setInteracting(bool value) {
    _isInteracting = value;
    notifyListeners();
  }

  Future<void> handleDragUpdate(
      CharacterModel character, Offset newPosition) async {
    if (!_isDragging && !_isInteracting) return;

    try {
      final adjustedPosition = _validatePosition(newPosition);
      if (!_checkCollision(adjustedPosition.dx, adjustedPosition.dy,
          excludeId: character.id)) {
        await moveCharacter(
          character,
          adjustedPosition.dx,
          adjustedPosition.dy,
        );
      }
    } catch (e) {
      _error = 'Erro ao mover personagem: $e';
      notifyListeners();
    }
  }

  // Melhorar validação de posição
  Offset _validatePosition(Offset position) {
    final padding =
        50.0; // Evita que os cartões fiquem muito próximos das bordas
    return Offset(
      position.dx.clamp(padding, canvasWidth - padding),
      position.dy.clamp(padding, canvasHeight - padding),
    );
  }
}
