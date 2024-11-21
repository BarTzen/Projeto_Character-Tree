import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/character_viewmodel.dart';
import '../widgets/auth/user_avatar.dart';
import '../widgets/characters/character_canvas.dart';

class TreeView extends StatefulWidget {
  final String treeId;

  const TreeView({super.key, required this.treeId});

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  void _showAddCharacterDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Personagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final characterVM = context.read<CharacterViewModel>();
              characterVM.createCharacter(
                widget.treeId,
                nameController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/tree_logo_alt.png',
          fit: BoxFit.contain,
          height: 48,
        ),
        backgroundColor: Colors.blueGrey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCharacterDialog,
          ),
          const UserAvatar(),
        ],
      ),
      body: Consumer<CharacterViewModel>(
        builder: (context, characterVM, child) {
          if (characterVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CharacterCanvas(
            characters: characterVM.characters,
            onCharacterMoved: characterVM.updateCharacterPosition,
            onCharacterConnected: (sourceId, targetId, relationshipType) =>
                characterVM.connectCharacters(
              sourceId,
              targetId,
              connectionType:
                  relationshipType, // Changed from relationship to connectionType
            ),
          );
        },
      ),
    );
  }
}
