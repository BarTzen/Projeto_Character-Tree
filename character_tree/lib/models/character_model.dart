import 'dart:convert';

class CharacterModel {
  final String id; // Identificador único do personagem
  final String treeId; // ID da árvore genealógica associada
  final String name; // Nome do personagem
  final String? description; // Descrição do personagem (opcional)
  final DateTime createdAt; // Data de criação do personagem
  final DateTime lastEdited; // Data da última edição
  final Map<String, dynamic> position; // Posição do personagem no canvas {x, y}
  final List<String> connectedCharacters; // IDs de personagens conectados
  final List<String> connections; // Lista de IDs de personagens conectados
  final String? imageUrl; // URL da imagem do personagem
  final Map<String, dynamic> attributes; // Atributos customizados
  final Map<String, String>
      relationships; // Tipo de relacionamento com outros personagens

  CharacterModel({
    required this.id,
    required this.treeId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastEdited,
    required this.position,
    required this.connectedCharacters,
    List<String>? connections,
    this.imageUrl,
    Map<String, dynamic>? attributes,
    Map<String, String>? relationships,
  })  : connections = connections ?? [],
        attributes = attributes ?? {},
        relationships = relationships ?? {};

  /// Atualiza a posição do personagem.
  CharacterModel updatePosition(double x, double y) {
    return CharacterModel(
      id: id,
      treeId: treeId,
      name: name,
      description: description,
      createdAt: createdAt,
      lastEdited: DateTime.now(),
      position: {'x': x, 'y': y},
      connectedCharacters: connectedCharacters,
      connections: connections,
      imageUrl: imageUrl,
      attributes: attributes,
      relationships: relationships,
    );
  }

  /// Adiciona uma conexão com outro personagem.
  CharacterModel addConnection(String characterId) {
    return CharacterModel(
      id: id,
      treeId: treeId,
      name: name,
      description: description,
      createdAt: createdAt,
      lastEdited: DateTime.now(),
      position: position,
      connectedCharacters: [...connectedCharacters, characterId],
      connections: connections,
      imageUrl: imageUrl,
      attributes: attributes,
      relationships: relationships,
    );
  }

  /// Remove uma conexão com outro personagem.
  CharacterModel removeConnection(String characterId) {
    return CharacterModel(
      id: id,
      treeId: treeId,
      name: name,
      description: description,
      createdAt: createdAt,
      lastEdited: DateTime.now(),
      position: position,
      connectedCharacters:
          connectedCharacters.where((id) => id != characterId).toList(),
      connections: connections,
      imageUrl: imageUrl,
      attributes: attributes,
      relationships: relationships,
    );
  }

  /// Adiciona um relacionamento com outro personagem.
  CharacterModel addRelationship(String targetId, String relationType) {
    final newRelationships = Map<String, String>.from(relationships);
    newRelationships[targetId] = relationType;

    return copyWith(relationships: newRelationships);
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
    List<String>? connectedCharacters,
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
      connectedCharacters: connectedCharacters ?? this.connectedCharacters,
      connections: connections ?? this.connections,
      imageUrl: imageUrl ?? this.imageUrl,
      attributes: attributes ?? this.attributes,
      relationships: relationships ?? this.relationships,
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
      'position': position,
      'connectedCharacters': connectedCharacters,
      'connections': connections,
      'imageUrl': imageUrl,
      'attributes': attributes,
      'relationships': relationships,
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
      position: Map<String, dynamic>.from(map['position']),
      connectedCharacters: List<String>.from(map['connectedCharacters'] ?? []),
      connections: List<String>.from(map['connections'] ?? []),
      imageUrl: map['imageUrl'],
      attributes: Map<String, dynamic>.from(map['attributes'] ?? {}),
      relationships: Map<String, String>.from(map['relationships'] ?? {}),
    );
  }

  /// Converte o modelo para JSON (opcional).
  String toJson() => json.encode(toMap());

  /// Cria o modelo a partir de JSON (opcional).
  factory CharacterModel.fromJson(String source) =>
      CharacterModel.fromMap(json.decode(source));
}
