class UserModel {
  final String? id; // Agora UUID em vez de int
  final String username;
  final String name;
  final String email;

  UserModel({
    this.id,
    required this.username,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
    };
  }
}
