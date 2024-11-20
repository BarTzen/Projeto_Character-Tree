import 'package:flutter/material.dart';

class CharacterModel {
  final String id;
  final String name;
  final Offset position;

  CharacterModel({
    required this.id,
    required this.name,
    required this.position,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> data) {
    return CharacterModel(
      id: data['id'],
      name: data['name'],
      position: Offset(data['x'], data['y']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'x': position.dx,
      'y': position.dy,
    };
  }
}
