import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/genealogy/genealogy_viewmodel.dart';

class CreateGenealogyScreen extends StatelessWidget {
  const CreateGenealogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final genealogyViewModel = context.watch<GenealogyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('lib/assets/images/tree_logo_alt.png'),
            const SizedBox(width: 8),
            const Spacer(),
            CircleAvatar(
              child: Text(
                  'A'), // Replace 'A' with the first letter of the user's name
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TÍTULO "CRIAR GENEALOGIA"
                  Text(
                    'Criar Genealogia Literária',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CAMPO DE NOME DA GENEALOGIA
                  TextFormField(
                    onChanged: genealogyViewModel.setGenealogyName,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.account_tree, color: Colors.black54),
                      hintText: 'Nome da Genealogia',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE NOME DO LIVRO
                  TextFormField(
                    onChanged: genealogyViewModel.setBookName,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.book, color: Colors.black54),
                      hintText: 'Nome do Livro',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO "ADICIONAR IMAGEM"
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Adicionar Imagem'),
                    onPressed: () {
                      // Logic to upload image
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE NOME DO PERSONAGEM PRINCIPAL
                  TextFormField(
                    onChanged: genealogyViewModel.setMainCharacterName,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.black54),
                      hintText: 'Nome do Personagem Principal',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO "ADICIONAR PERSONAGEM RAIZ"
                  ElevatedButton(
                    onPressed: () {
                      // Logic to add main character
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Adicionar Personagem Raiz'),
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO "PRÉ-VISUALIZAÇÃO"
                  ElevatedButton(
                    onPressed: () {
                      // Logic to preview genealogy
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Pré-visualização'),
                  ),
                  const SizedBox(height: 20),

                  // BOTÃO "SALVAR"
                  ElevatedButton(
                    onPressed: genealogyViewModel.saveGenealogy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Salvar'),
                  ),
                  const SizedBox(height: 10),

                  // BOTÃO "CANCELAR"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
