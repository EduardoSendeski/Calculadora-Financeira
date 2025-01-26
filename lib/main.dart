import 'package:flutter/material.dart';
import 'telas/login.dart';
import 'telas/splash_screen.dart';
import 'telas/tela_inicial.dart'; // Adicione o caminho correto para as telas
import 'telas/tela_resultado.dart'; // Adicione o caminho correto para as telas

void main() {
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
      initialRoute: '/', // Rota inicial
      routes: {
        '/': (context) => const SplashScreen(), // Tela inicial ajustada
        '/login': (context) => const LoginPage(), // Tela de login
        '/telaInicial': (context) => const TelaInicial(), // Tela inicial (antiga)
        '/resultado': (context) => const TelaResultado(), // Tela de resultados
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login'); // Usa a rota definida
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
