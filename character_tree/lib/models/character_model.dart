import 'package:character_tree/utils/relation_type.dart';

class CharacterModel {
  static const int currentVersion = 1;
  final int version;
  final String id;
  final String treeId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastEdited;
  final Map<String, double> _position;
  final List<String> connections;
  final String? imageUrl;
  final Map<String, dynamic> attributes;
  final Map<String, String> relationships;

  CharacterModel({
    required this.id,
    required this.treeId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastEdited,
    required Map<String, dynamic> position,
    List<String>? connections,
    this.imageUrl,
    Map<String, dynamic>? attributes,
    Map<String, String>? relationships,
    this.version = currentVersion,
  })  : _position = {
          'x': (position['x'] ?? 0.0).toDouble(),
          'y': (position['y'] ?? 0.0).toDouble(),
        },
        connections = connections ?? [],
        attributes = attributes ?? {},
        relationships = relationships ?? {};

  /// Garanta que a posição sempre seja um Map<String, double>
  Map<String, double> get position {
    return {
      'x': (_position['x'] ?? 0.0).toDouble(),
      'y': (_position['y'] ?? 0.0).toDouble(),
    };
  }

  /// Atualiza a posição do personagem.
  CharacterModel updatePosition(double x, double y) {
    return copyWith(
      position: {'x': x, 'y': y},
      lastEdited: DateTime.now(),
    );
  }

  /// Remove uma conexão com outro personagem.
  CharacterModel removeConnection(String characterId) {
    final newRelationships = Map<String, String>.from(relationships)
      ..remove(characterId);
    return copyWith(
      connections: connections.where((id) => id != characterId).toList(),
      relationships: newRelationships,
      lastEdited: DateTime.now(),
    );
  }

  /// Adiciona um relacionamento tipado com outro personagem
  CharacterModel addTypedRelationship(String targetId, RelationType type) {
    final newRelationships = Map<String, String>.from(relationships);
    newRelationships[targetId] = type.name;
    return copyWith(
      relationships: newRelationships,
      connections: [...connections, targetId],
      lastEdited: DateTime.now(),
    );
  }

  /// Método utilitário para cópia com modificações.
  CharacterModel copyWith({
    String? id,
    String? treeId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? lastEdited,
    Map<String, dynamic>? position,
    List<String>? connections,
    String? imageUrl,
    Map<String, dynamic>? attributes,
    Map<String, String>? relationships,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
      position: position ?? this.position,
      connections: connections ?? this.connections,
      imageUrl: imageUrl ?? this.imageUrl,
      attributes: attributes ?? this.attributes,
      relationships: relationships ?? this.relationships,
    );
  }

  /// Cria um modelo vazio
  factory CharacterModel.empty() {
    return CharacterModel(
      id: '',
      treeId: '',
      name: '',
      createdAt: DateTime.now(),
      lastEdited: DateTime.now(),
      position: {'x': 0.0, 'y': 0.0},
    );
  }

  /// Converte o modelo para um mapa (para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'treeId': treeId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
      'position': {
        'x': position['x'],
        'y': position['y'],
      },
      'connections': connections,
      'imageUrl': imageUrl,
      'attributes': attributes,
      'relationships': relationships,
      'version': version,
    };
  }

  /// Cria o modelo a partir de um mapa (para carregar do Firestore).
  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] ?? '',
      treeId: map['treeId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: DateTime.parse(map['lastEdited']),
      position: {
        'x': (map['position']['x'] ?? 0.0).toDouble(),
        'y': (map['position']['y'] ?? 0.0).toDouble(),
      },
      connections: List<String>.from(map['connections'] ?? []),
      imageUrl: map['imageUrl'],
      attributes: Map<String, dynamic>.from(map['attributes'] ?? {}),
      relationships: Map<String, String>.from(map['relationships'] ?? {}),
      version: map['version'] ?? currentVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
