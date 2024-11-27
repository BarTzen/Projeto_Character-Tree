import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class UserModel {
  static const int currentVersion = 1;
  final int version;
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
    this.version = currentVersion,
  });

  /// Gera uma cor para o avatar baseada no email do usuário
  /// Esta cor será consistente para o mesmo email
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

  /// Retorna a inicial do usuário para exibição no avatar
  /// Prioriza o nome, depois email e por último '?' como fallback
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
      'nome': name, // Alterado para 'nome'
      'email': email,
      'avatarUrl': avatarUrl,
      'avatarColor': avatarColor.value, // Armazena a cor como int
      'dataCriacao': createdAt.toIso8601String(), // Alterado para 'dataCriacao'
      'ultimoLogin': lastLogin.toIso8601String(), // Alterado para 'ultimoLogin'
    };
  }

  /// Cria o modelo a partir de um mapa (para carregar do Firestore).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['nome'] ?? '', // Alterado para 'nome'
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      avatarColor: Color(map['avatarColor'] ?? Colors.grey.value),
      createdAt:
          DateTime.parse(map['dataCriacao']), // Alterado para 'dataCriacao'
      lastLogin:
          DateTime.parse(map['ultimoLogin']), // Alterado para 'ultimoLogin'
    );
  }

  /// Converte o modelo para JSON.
  String toJson() => json.encode(toMap());

  /// Cria o modelo a partir de JSON.
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

  static bool isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);

  static bool isValidUrl(String? url) =>
      url == null || Uri.tryParse(url)?.hasAbsolutePath == true;

  /// Valida os dados do usuário
  /// Lança [ValidationException] se encontrar dados inválidos
  void validate() {
    if (id.isEmpty || id.length < 3) {
      throw ValidationException(
          'ID inválido - deve ter pelo menos 3 caracteres');
    }
    if (name.isEmpty || name.length < 2) {
      throw ValidationException(
          'Nome inválido - deve ter pelo menos 2 caracteres');
    }
    if (!isValidEmail(email)) throw ValidationException('Email inválido');
    if (avatarUrl != null && !isValidUrl(avatarUrl)) {
      throw ValidationException('URL do avatar inválida');
    }
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

// ...existing code...

/// Remover campos ou métodos não utilizados
// Exemplo: Se `avatarColor` não é utilizado na UI, considerar removê-lo.

// ...existing code...
