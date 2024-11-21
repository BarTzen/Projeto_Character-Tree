import 'dart:convert';

class TreeModel {
  final String id; // Identificador único da árvore
  final String userId; // ID do usuário que criou a árvore
  final String name; // Nome da árvore
  final String? coverImageUrl; // URL opcional da imagem de capa
  final int characterCount; // Número de personagens na árvore
  final DateTime createdAt; // Data de criação da árvore
  final DateTime lastEdited; // Data da última edição

  TreeModel({
    required this.id,
    required this.userId,
    required this.name,
    this.coverImageUrl,
    required this.characterCount,
    required this.createdAt,
    required this.lastEdited,
  });

  /// Atualiza a contagem de personagens na árvore.
  TreeModel updateCharacterCount(int newCount) {
    return TreeModel(
      id: id,
      userId: userId,
      name: name,
      coverImageUrl: coverImageUrl,
      characterCount: newCount,
      createdAt: createdAt,
      lastEdited: DateTime.now(),
    );
  }

  /// Converte o modelo para um mapa (para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'coverImageUrl': coverImageUrl,
      'characterCount': characterCount,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
    };
  }

  /// Cria o modelo a partir de um mapa (para carregar do Firestore).
  factory TreeModel.fromMap(Map<String, dynamic> map) {
    return TreeModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      characterCount: map['characterCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: DateTime.parse(map['lastEdited']),
    );
  }

  /// Converte o modelo para JSON (opcional).
  String toJson() => json.encode(toMap());

  /// Cria o modelo a partir de JSON (opcional).
  factory TreeModel.fromJson(String source) =>
      TreeModel.fromMap(json.decode(source));
}
