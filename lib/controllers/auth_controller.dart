import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> register(String username, String name, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'name': name},
      );

      if (response.user != null) {
        return null; // Cadastro bem-sucedido
      } else {
        return "Erro ao cadastrar usuário.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
