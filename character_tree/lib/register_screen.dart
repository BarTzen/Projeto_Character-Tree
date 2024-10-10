import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importa a tela de login para navegação
import 'create_genealogy_screen.dart'; // Importa a tela de criação de genealogia

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                'Crie sua conta para começar a explorar as genealogias literárias',
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
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Usuário',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirmar senha',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Continuar'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateGenealogyScreen()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Já tem uma conta?"),
                    TextButton(
                      child: const Text(
                        "Conecte-se",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
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
}
