import 'package:flutter/material.dart';

class CreateGenealogyScreen extends StatelessWidget {
  const CreateGenealogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Genealogia Literária'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Nome da Genealogia',
                  prefixIcon: Icon(Icons.account_tree),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Nome do Livro',
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Nome do Personagem Principal',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Salvar'),
                onPressed: () {
                  // Lógica para salvar a genealogia
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Árvore genealógica literária foi criada!')),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  // Lógica para cancelar a criação da genealogia
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Árvore genealógica literária não foi criada.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
