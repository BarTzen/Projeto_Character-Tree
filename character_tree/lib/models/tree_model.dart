import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:character_tree/models/user_model.dart';

class TreeModel {
  static const int currentVersion = 1;
  final int version;
  final String id; // Identificador único da árvore
  final String userId; // ID do usuário que criou a árvore
  final String name; // Nome da árvore
  final String? coverImageUrl; // URL opcional da imagem de capa
  final int characterCount; // Número de personagens na árvore
  final DateTime createdAt; // Data de criação da árvore
  final DateTime lastEdited; // Data da última edição
  DocumentSnapshot? docSnapshot;

  TreeModel({
    required this.id,
    required this.userId,
    required this.name,
    this.coverImageUrl,
    required this.characterCount,
    required this.createdAt,
    required this.lastEdited,
    this.version = currentVersion,
    this.docSnapshot,
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
      version: version,
      docSnapshot: docSnapshot,
    );
  }

  /// Valida os dados da árvore
  /// Lança [ValidationException] se encontrar dados inválidos
  void validate() {
    if (id.isEmpty) throw ValidationException('ID não pode ser vazio');
    if (userId.isEmpty) {
      throw ValidationException('ID do usuário não pode ser vazio');
    }
    if (name.length < 2) throw ValidationException('Nome muito curto');
    if (characterCount < 0) throw ValidationException('Contagem inválida');
    if (coverImageUrl != null && !UserModel.isValidUrl(coverImageUrl)) {
      throw ValidationException('URL inválida');
    }
  }

  /// Cria uma cópia da árvore com dados atualizados
  TreeModel copyWith({
    String? name,
    String? coverImageUrl,
    int? characterCount,
    DocumentSnapshot? docSnapshot,
  }) {
    return TreeModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      characterCount: characterCount ?? this.characterCount,
      createdAt: createdAt,
      lastEdited: DateTime.now(),
      version: version,
      docSnapshot: docSnapshot ?? this.docSnapshot,
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
      'version': version,
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
      version: map['version'] ?? currentVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ...existing code...

/// Remover campos que não são necessários ou utilizados
// Exemplo: Se `version` não está sendo utilizado, pode ser removido.

// ...existing code...

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
