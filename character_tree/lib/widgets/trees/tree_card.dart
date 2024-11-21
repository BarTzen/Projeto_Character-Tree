import 'package:flutter/material.dart';
import '../../models/tree_model.dart';
import '../../view/tree_view.dart';

class TreeCard extends StatelessWidget {
  final TreeModel tree;

  const TreeCard({super.key, required this.tree});

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
                tree.characterCount > 0 ? Icons.account_tree : Icons.add_chart,
                color: Colors.white,
              ),
            ),
            title: Text(
              tree.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Criada em: ${_formatDate(tree.createdAt)}\n'
              'Personagens: ${tree.characterCount}',
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
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Implementar diálogo de edição
  }

  void _navigateToTree(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeView(treeId: tree.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
