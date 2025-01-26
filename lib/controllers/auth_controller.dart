import '../model/user_model.dart';
import '../services/database_helper.dart';

class AuthController {
  final dbHelper = DatabaseHelper();

  Future<String?> register(UserModel user) async {
    final existingUser = await dbHelper.getUserByUsernameOrEmail(user.username, user.email);
    if (existingUser != null) {
      return "Usuário ou e-mail já cadastrado.";
    }
    await dbHelper.insertUser(user.toMap());
    return null;
  }

  Future<UserModel?> login(String username, String password) async {
    final user = await dbHelper.getUser(username, password);
    if (user != null) {
      return UserModel(
        id: user['id'],
        username: user['username'],
        name: user['name'],
        email: user['email'],
        password: user['password'],
      );
    }
    return null;
  }
}
