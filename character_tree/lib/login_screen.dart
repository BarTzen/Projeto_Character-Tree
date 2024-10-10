import 'package:flutter/material.dart';
import 'register_screen.dart'; // Importa a tela de cadastro para navegação
import 'create_genealogy_screen.dart'; // Importa a tela de criação de genealogia

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  void _validateLogin() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == 'aluno@sou.faccat.br' && password == 'aluno') {
      // Login bem-sucedido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login bem-sucedido.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateGenealogyScreen()),
      );
    } else {
      // Exibe uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou Senha incorretos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                  'lib/assets/tree_logo.png'), // Substitua pelo caminho do seu logo
              const SizedBox(height: 20),
              const Text(
                'Entre para continuar sua jornada genealógica literária',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('lib/assets/google_logo.png',
                    height: 24), // Substitua pelo caminho do logo do Google
                label: const Text('Continuar com o Google'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateGenealogyScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                child: const Text('Esqueceu sua senha?'),
                onPressed: () {
                  // Lógica para recuperação de senha
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateLogin,
                child: const Text('Continuar'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Não tem uma conta?"),
                    TextButton(
                      child: const Text(
                        "Cadastre-se agora",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
