import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tree_model.dart';
import '../../view/tree_view.dart';
import '../../viewmodel/tree_viewmodel.dart'; // Adicionar import correto

class TreeCard extends StatefulWidget {
  final TreeModel tree;

  const TreeCard({super.key, required this.tree});

  @override
  State<TreeCard> createState() => _TreeCardState();
}

class _TreeCardState extends State<TreeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(
                widget.tree.characterCount > 0
                    ? Icons.account_tree
                    : Icons.add_chart,
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.tree.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Criada em: ${_formatDate(widget.tree.createdAt)}\n'
              'Personagens: ${widget.tree.characterCount}',
            ),
            isThreeLine: true,
          ),
          OverflowBar(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                onPressed: () => _showEditDialog(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('Visualizar'),
                onPressed: () => _navigateToTree(context),
              ),
              IconButton(
                // Adicionar ícone de delete
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: widget.tree.name);
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Editar Árvore Literária'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Árvore',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'O nome da árvore é obrigatório';
              }
              if (value.trim().length < 3) {
                return 'O nome deve ter pelo menos 3 caracteres';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          StatefulBuilder(
            builder: (context, setState) => TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);

                      // Store references before async operation
                      final navigator = Navigator.of(dialogContext);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final treeVM =
                          Provider.of<TreeViewModel>(context, listen: false);

                      try {
                        await treeVM.updateTree(
                          widget.tree.id,
                          nameController.text.trim(),
                        );

                        if (!mounted) return;
                        setState(() => isSubmitting = false);

                        if (navigator.mounted) {
                          navigator.pop();
                        }

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Árvore atualizada com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => isSubmitting = false);
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar árvore: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTree(BuildContext context) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeView(treeId: widget.tree.id),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Árvore'),
        content: const Text('Tem certeza que deseja excluir esta árvore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final treeVM = Provider.of<TreeViewModel>(context, listen: false);
              treeVM.deleteTree(widget.tree.id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
