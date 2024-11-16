class CharacterModel {
  final String id;
  final String name;
  final String role;
  final String treeId;

  CharacterModel({
    required this.id,
    required this.name,
    required this.role,
    required this.treeId,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> data) {
    return CharacterModel(
      id: data['id'],
      name: data['name'],
      role: data['role'],
      treeId: data['treeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'treeId': treeId,
    };
  }
}
