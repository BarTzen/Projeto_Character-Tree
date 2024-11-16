class UserModel {
  final String id;
  final String username;
  final String email;
  final String profileColor;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.profileColor,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      profileColor: data['profileColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileColor': profileColor,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profileColor,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileColor: profileColor ?? this.profileColor,
    );
  }
}
