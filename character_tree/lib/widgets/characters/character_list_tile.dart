import 'package:flutter/material.dart';
import '../../models/character_model.dart';

/// Componente visual para exibir informações de um personagem em uma lista.
/// Inclui ações para editar e excluir o personagem.
class CharacterListTile extends StatelessWidget {
  final CharacterModel character; // Modelo do personagem a ser exibido.
  final VoidCallback onEdit; // Callback para editar o personagem.
  final VoidCallback onDelete; // Callback para excluir o personagem.

  const CharacterListTile({
    super.key,
    required this.character,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          character.name.isNotEmpty
              ? character.name[0].toUpperCase() // Exibe a inicial do nome.
              : '?', // Mostra '?' se o nome estiver vazio.
        ),
      ),
      title: Text(
        character.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        character.description ??
            'Sem descrição.', // Texto padrão se descrição estiver nula.
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Mantém os ícones compactos.
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit, // Chama o callback para editar.
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Exibe uma confirmação antes de excluir.
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content:
                      Text('Deseja realmente excluir "${character.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx), // Fecha o diálogo.
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Fecha o diálogo.
                        onDelete(); // Executa a exclusão.
                      },
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
