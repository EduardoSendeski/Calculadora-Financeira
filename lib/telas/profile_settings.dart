import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_helper.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _profileUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// **Carrega os dados do usuário logado**
  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuário não autenticado.")));
      return;
    }

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        _nameController.text = response['name'] ?? '';
        _profileUrl = response['profile_url'] ?? '';
      });
    } else {
      debugPrint("❌ Usuário não encontrado no banco de dados.");
    }
  }

  /// **Seleciona uma nova foto de perfil**
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

/// **Faz o upload da nova foto para o Supabase Storage e retorna a URL**
Future<String?> _uploadImage(String userId) async {
  if (_image == null) return _profileUrl; // Mantém a foto atual se o usuário não mudou

  final fileExt = _image!.path.split('.').last;
  final fileName = "$userId.$fileExt"; // Nome do arquivo baseado no userId
  final filePath = 'profile_pictures/$fileName';

  try {
    // Remove a imagem anterior para evitar arquivos duplicados
    await Supabase.instance.client.storage.from('profile_pictures').remove([filePath]);

    // Faz o upload da nova imagem
    await Supabase.instance.client.storage.from('profile_pictures').upload(
      filePath,
      _image!,
      fileOptions: const FileOptions(upsert: true), // Sobrescreve se já existir
    );

    // Obtém a URL pública da nova imagem e adiciona um timestamp para evitar cache
    final imageUrl = "${Supabase.instance.client.storage.from('profile_pictures').getPublicUrl(filePath)}?t=${DateTime.now().millisecondsSinceEpoch}";

    debugPrint("✅ Upload da imagem concluído: $imageUrl");
    return imageUrl;
  } catch (e) {
    debugPrint("❌ Erro ao fazer upload da imagem: $e");
    return _profileUrl; // Retorna a URL antiga se der erro no upload
  }
}



  Future<void> _saveProfile() async {
  setState(() => _isLoading = true);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    debugPrint("❌ ERRO: Nenhum usuário autenticado.");
    return;
  }

  debugPrint("🔍 ID do usuário autenticado: ${user.id}");

  final imageUrl = await _uploadImage(user.id); // Faz upload e pega a URL

  try {
    // Atualiza os dados do usuário no Supabase
    await dbHelper.updateUserProfile(user.id, _nameController.text.trim(), imageUrl);

    debugPrint("🔄 Recarregando dados do usuário...");

    // Aguarda a atualização e carrega os novos dados
    await _loadUserProfile();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Perfil atualizado com sucesso!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Erro ao atualizar perfil: $e")));
  } finally {
    setState(() => _isLoading = false);
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text("Configurações de Perfil"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAvatar(),
                const SizedBox(height: 20),
                _buildTextField("Nome", Icons.person, _nameController),
                const SizedBox(height: 20),
                _buildTextField("Nova Senha", Icons.lock, _passwordController, isPassword: true),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Ícone para alterar a foto de perfil**
  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: _image != null
              ? FileImage(_image!)
              : (_profileUrl != null && _profileUrl!.isNotEmpty ? NetworkImage(_profileUrl!) : null) as ImageProvider?,
          child: (_image == null && (_profileUrl == null || _profileUrl!.isEmpty))
              ? const Icon(Icons.person, size: 50, color: Colors.green)
              : null,
        ),
      ),
    );
  }

  /// **Campo de entrada customizado**
  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  /// **Botão de Salvar**
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.green)
          : const Center(
              child: Text(
                "SALVAR ALTERAÇÕES",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
