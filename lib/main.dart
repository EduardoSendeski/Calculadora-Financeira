import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'telas/login.dart';
import 'telas/splash_screen.dart';
import 'telas/tela_inicial.dart';
import 'telas/tela_resultado.dart';

// URL e chave do Supabase
const supabaseUrl = 'https://vheeiznftsmkkbihedrs.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoZWVpem5mdHNta2tiaWhlZHJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAzMzUzNjEsImV4cCI6MjA1NTkxMTM2MX0.eV63tbBxwn-QZiHKoqhdi3rta_x_YTy5GEdvs4trgSE';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Tentativa de inicializar o Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: true, // Log para acompanhar erros
    );
    debugPrint("✅ Supabase conectado com sucesso!");
  } catch (e, stacktrace) {
    debugPrint("❌ Erro ao conectar no Supabase: $e");
    debugPrint(stacktrace.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Financeira',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/telaInicial': (context) => const TelaInicial(),
        '/resultado': (context) => const TelaResultado(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
