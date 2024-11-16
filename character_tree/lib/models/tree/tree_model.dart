class TreeModel {
  final String id;
  final String name;
  final String bookName;
  final String mainCharacterName;
  final String? imagePath;

  TreeModel({
    required this.id,
    required this.name,
    required this.bookName,
    required this.mainCharacterName,
    this.imagePath,
  });

  factory TreeModel.fromMap(Map<String, dynamic> data) {
    return TreeModel(
      id: data['id'],
      name: data['name'],
      bookName: data['bookName'],
      mainCharacterName: data['mainCharacterName'],
      imagePath: data['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bookName': bookName,
      'mainCharacterName': mainCharacterName,
      'imagePath': imagePath,
    };
  }
}
