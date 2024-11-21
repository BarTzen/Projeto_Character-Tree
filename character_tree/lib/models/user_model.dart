import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl; // Pode ser nulo se não houver avatar fornecido
  final Color avatarColor; // Cor do avatar gerada ou armazenada
  final DateTime createdAt; // Data de criação do usuário
  final DateTime lastLogin; // Data do último login

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.avatarColor,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Gera a cor do avatar com base na hash do email (para consistência).
  /// Usada apenas se a cor não for carregada do Firestore.
  static Color generateAvatarColor(String email) {
    final hash = email.hashCode;
    final random = Random(hash);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// Retorna a primeira letra do nome ou do email para exibir no avatar.
  String get avatarInitial {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?'; // Caso extremo onde não há nome ou email
  }

  /// Converte o modelo para um mapa (para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatarColor': avatarColor.value, // Armazena a cor como int
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  /// Cria o modelo a partir de um mapa (para carregar do Firestore).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      avatarColor: Color(map['avatarColor'] ?? Colors.grey.value),
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: DateTime.parse(map['lastLogin']),
    );
  }

  /// Converte o modelo para JSON (opcional, se necessário).
  String toJson() => json.encode(toMap());

  /// Cria o modelo a partir de JSON (opcional, se necessário).
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  /// Cria uma cópia do UserModel com dados atualizados
  UserModel copyWith({
    String? name,
    String? avatarUrl,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  void validate() {
    if (id.isEmpty) throw ValidationException('ID não pode ser vazio');
    if (name.isEmpty) throw ValidationException('Nome não pode ser vazio');
    if (!isValidEmail(email)) throw ValidationException('Email inválido');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}
