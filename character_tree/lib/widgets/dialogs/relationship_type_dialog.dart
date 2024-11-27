import 'package:flutter/material.dart';
import '../../models/relationship_type.dart';

/// Diálogo para selecionar o tipo de relacionamento entre personagens.
class RelationshipTypeDialog extends StatelessWidget {
  final Function(RelationType) onSelected; // Callback para selecionar o tipo.

  const RelationshipTypeDialog({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Borda arredondada.
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adapta o tamanho ao conteúdo.
          children: [
            const Text(
              'Tipo de Relacionamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Lista de tipos de relacionamento.
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: RelationType.values.map((type) {
                    return ListTile(
                      leading: Hero(
                        tag: type.name, // Tag para animação Hero.
                        child: Icon(_getRelationshipIcon(type)),
                      ),
                      title: Text(type.description),
                      onTap: () {
                        onSelected(
                            type); // Chama o callback com o tipo selecionado.
                        Navigator.of(context).pop(); // Fecha o diálogo.
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna o ícone correspondente ao tipo de relacionamento.
  IconData _getRelationshipIcon(RelationType type) {
    switch (type) {
      case RelationType.parent:
        return Icons.family_restroom;
      case RelationType.spouse:
        return Icons.favorite;
      case RelationType.sibling:
        return Icons.people;
      default:
        return Icons.link;
    }
  }
}
