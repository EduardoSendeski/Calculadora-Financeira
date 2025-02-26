import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  bool _isLoading = false;
  File? _image; // Armazena a imagem selecionada
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Criar Conta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAvatar(),
                const SizedBox(height: 40),
                _buildTextField("Usuário", Icons.person, _usernameController),
                const SizedBox(height: 20),
                _buildTextField("Nome", Icons.badge, _nameController),
                const SizedBox(height: 20),
                _buildTextField("E-mail", Icons.email, _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField("Senha", Icons.lock, _passwordController, isPassword: true),
                const SizedBox(height: 20),
                _buildTextField("Confirmar Senha", Icons.lock, _confirmPasswordController, isPassword: true),
                const SizedBox(height: 20),
                _buildRegisterButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Ícone onde o usuário pode escolher uma imagem**
  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null ? const Icon(Icons.add_a_photo, size: 50, color: Colors.green) : null,
        ),
      ),
    );
  }

  /// **Seleciona uma imagem da galeria**
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

/// **Faz o upload da imagem para o Supabase Storage e retorna a URL pública**
Future<String?> _uploadImage(String userId) async {
  if (_image == null) return null;

  final fileExt = _image!.path.split('.').last; // Obtém a extensão do arquivo
  final fileName = "$userId.$fileExt"; // Nome do arquivo no storage
  final filePath = 'profile_pictures/$fileName'; // Caminho no Supabase Storage

  try {
    // Apaga qualquer imagem anterior do usuário
    await Supabase.instance.client.storage.from('profile_pictures').remove([filePath]);

    // Faz o upload da nova imagem
    final response = await Supabase.instance.client.storage.from('profile_pictures').upload(
      filePath,
      _image!,
      fileOptions: const FileOptions(upsert: true),
    );

    if (response.isEmpty) {
      debugPrint("❌ Erro: O Supabase não retornou uma resposta válida.");
      return null;
    }

    // Obtém a URL pública da imagem
    final imageUrl = Supabase.instance.client.storage.from('profile_pictures').getPublicUrl(filePath);
    
    debugPrint("✅ Upload da imagem concluído: $imageUrl");
    return imageUrl;
  } catch (e) {
    debugPrint("❌ Erro ao fazer upload da imagem: $e");
    return null;
  }
}


  /// **Realiza o cadastro do usuário**
Future<void> _registerUser() async {
  final username = _usernameController.text.trim();
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (!_validateFields(username, name, email, password, confirmPassword)) return;

  setState(() => _isLoading = true);

  try {
    // Cria o usuário no Supabase Auth
    final response = await Supabase.instance.client.auth.signUp(email: email, password: password);

    if (response.user != null) {
      // Faz o upload da imagem e obtém a URL
      final imageUrl = await _uploadImage(response.user!.id);

      // Insere os dados do usuário no banco de dados
      await dbHelper.insertUser({
        'id': response.user!.id, 
        'username': username,
        'name': name,
        'email': email,
        'profile_url': imageUrl ?? '', // Salva a URL da imagem no banco
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Usuário cadastrado com sucesso!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Erro ao criar usuário.')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Erro ao cadastrar: $e')));
  } finally {
    setState(() => _isLoading = false);
  }
}


  /// **Botão de Cadastro**
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _registerUser,
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
                "CADASTRAR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  /// **Link para Login**
  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "Já tem uma conta? Faça login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// **Valida os campos do formulário antes do cadastro**
bool _validateFields(String username, String name, String email, String password, String confirmPassword) {
  if (username.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ Preencha todos os campos.')),
    );
    return false;
  }

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ A senha deve ter pelo menos 6 caracteres.')),
    );
    return false;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ As senhas não coincidem.')),
    );
    return false;
  }

  return true;
}

  /// **Campo de entrada customizado**
  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
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
}
