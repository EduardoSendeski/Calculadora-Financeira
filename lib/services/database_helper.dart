import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  final supabase = Supabase.instance.client;

  DatabaseHelper._internal();

  /// **Insere um usuário na tabela `users` do Supabase**
  Future<void> insertUser(Map<String, dynamic> user) async {
    try {
      // Verifica se o usuário já existe
      final existingUser = await getUserByUsernameOrEmail(user['username'], user['email']);
      if (existingUser != null) {
        throw Exception('⚠️ Usuário já existe');
      }

      // Insere no Supabase com URL da imagem
      await supabase.from('users').insert({
        'id': user['id'], // UUID gerado pelo Supabase Auth
        'username': user['username'],
        'name': user['name'],
        'email': user['email'],
        'profile_url': user['profile_url'], // Nova coluna para armazenar a imagem
      });

      debugPrint("✅ Usuário inserido com sucesso no Supabase!");
    } catch (e) {
      debugPrint("❌ Erro ao inserir usuário: $e");
      throw Exception('Erro ao inserir usuário: $e');
    }
  }

  /// **Faz upload da foto de perfil no Supabase Storage**
  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = "$userId.$fileExt";
      final filePath = 'profile_pictures/$fileName';

      // Upload para o Supabase Storage (com upsert para sobrescrever se já existir)
      await supabase.storage.from('profile_pictures').upload(filePath, imageFile, fileOptions: const FileOptions(upsert: true));

      // Obtém a URL pública da imagem
      final imageUrl = supabase.storage.from('profile_pictures').getPublicUrl(filePath);

      debugPrint("✅ Upload da foto de perfil concluído: $imageUrl");
      return imageUrl;
    } catch (e) {
      debugPrint("❌ Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  /// **Busca usuário pelo username ou email**
  Future<Map<String, dynamic>?> getUserByUsernameOrEmail(String username, String email) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .or('username.eq.$username,email.eq.$email')
          .limit(1)
          .maybeSingle();

      debugPrint(response != null ? "🔎 Usuário encontrado: $response" : "⚠️ Usuário não encontrado");
      return response;
    } catch (e) {
      debugPrint("❌ Erro ao buscar usuário por username/email: $e");
      return null;
    }
  }
/// **Atualiza o nome e a foto de perfil do usuário no Supabase**
Future<void> updateUserProfile(String userId, String newName, String? newProfileUrl) async {
  try {
    final updates = <String, dynamic>{
      'name': newName,
    };

    if (newProfileUrl != null && newProfileUrl.isNotEmpty) {
      updates['profile_url'] = newProfileUrl;
    }

    final response = await Supabase.instance.client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select();

    if (response.isEmpty) {
      debugPrint("❌ ERRO: Nenhuma linha foi atualizada. Verifique se o ID existe e se a política de acesso permite UPDATE.");
    } else {
      debugPrint("✅ Atualização concluída. Resposta: $response");
    }
  } catch (e) {
    debugPrint("❌ ERRO AO ATUALIZAR PERFIL: $e");
    throw Exception('Erro ao atualizar perfil: $e');
  }
}




  /// **Busca usuário pelo username**
  Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .limit(1)
          .maybeSingle();

      debugPrint(response != null ? "🔎 Usuário encontrado pelo username: $response" : "⚠️ Usuário não encontrado");
      return response;
    } catch (e) {
      debugPrint("❌ Erro ao buscar usuário pelo username: $e");
      return null;
    }
  }
}
