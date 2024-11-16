import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/genealogy/genealogy_viewmodel.dart';

class ViewGenealogyScreen extends StatelessWidget {
  const ViewGenealogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final genealogyViewModel = context.watch<GenealogyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizar Genealogia'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nome da Genealogia: ${genealogyViewModel.genealogyName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Nome do Livro: ${genealogyViewModel.bookName}',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Nome do Personagem Principal: ${genealogyViewModel.mainCharacterName}',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              genealogyViewModel.imagePath != null
                  ? Image.asset(genealogyViewModel.imagePath!)
                  : Text('Nenhuma imagem adicionada'),
            ],
          ),
        ),
      ),
    );
  }
}
