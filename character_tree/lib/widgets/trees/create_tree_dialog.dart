import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/tree_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';

class CreateTreeDialog extends StatefulWidget {
  const CreateTreeDialog({super.key});

  @override
  State<CreateTreeDialog> createState() => _CreateTreeDialogState();
}

class _CreateTreeDialogState extends State<CreateTreeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Future<void> _handleCreateTree() async {
    if (_nameController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome da árvore não pode ser vazio.')),
      );
      return;
    }

    final userId = context.read<AuthViewModel>().currentUser!.id;
    await context.read<TreeViewModel>().createTree(
          userId,
          _nameController.text.trim(),
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Árvore Literária'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome da Árvore',
            hintText: 'Ex: Personagens de Harry Potter',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira um nome';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleCreateTree,
          child: const Text('Criar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
