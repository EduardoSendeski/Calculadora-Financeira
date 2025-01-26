class UserModel {
  final int? id;
  final String username;
  final String name;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
