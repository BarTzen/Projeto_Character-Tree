import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false; // Controle da visibilidade da senha

  @override
  Widget build(BuildContext context) {
    final registerViewModel = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO DO APP
                  Image.asset(
                    'lib/assets/tree_logo.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  // MENSAGEM ABAIXO DO LOGO
                  Text(
                    'Crie sua conta para começar a explorar as\n'
                    'genealogias literárias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // TÍTULO "CRIAR UMA CONTA"
                  Text(
                    'Criar uma Conta',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // BOTÃO "CONTINUAR COM GOOGLE"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para login com Google
                      },
                      icon: Image.asset(
                        'lib/assets/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        'Continuar com Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // LINHA DIVISÓRIA COM "OU"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.blue[900]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.blue[900]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // CAMPO DE USUÁRIO
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.black54),
                      hintText: 'Usuário',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CAMPO DE EMAIL
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.black54),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CAMPO DE SENHA COM ÍCONE DE VISIBILIDADE
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      hintText: 'Senha',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CAMPO DE CONFIRMAR SENHA
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      hintText: 'Confirmar Senha',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // BOTÃO "CONTINUAR"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        registerViewModel.register(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _confirmPasswordController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: registerViewModel.isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TEXTO "JÁ TEM UMA CONTA? CONECTE-SE"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem uma conta?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Retorna para a tela de login
                        },
                        child: Text(
                          'Conecte-se',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
