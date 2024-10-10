import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importa a tela de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Define a tela de login como a tela inicial
    );
  }
}
