import 'package:character_tree/models/character_model.dart';
import 'package:character_tree/utils/relation_type.dart';
import 'package:flutter/material.dart';

/// Classe base para diálogos do aplicativo
abstract class BaseDialog extends StatelessWidget {
  const BaseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: buildDialogContent(context),
    );
  }

  Widget buildDialogContent(BuildContext context);
}

/// Diálogo para selecionar tipo de relacionamento
class RelationshipTypeDialog extends BaseDialog {
  final Function(RelationType) onSelected;

  const RelationshipTypeDialog({
    super.key,
    required this.onSelected,
  });

  @override
  Widget buildDialogContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tipo de Relacionamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: SingleChildScrollView(
              child: Column(
                children: RelationType.values
                    .map((type) => _buildRelationItem(context, type))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationItem(BuildContext context, RelationType type) {
    return ListTile(
      leading: Hero(
        tag: type.name,
        child: Icon(_getRelationshipIcon(type)),
      ),
      title: Text(type.description),
      onTap: () {
        onSelected(type);
        Navigator.of(context).pop();
      },
    );
  }

  IconData _getRelationshipIcon(RelationType type) {
    return switch (type) {
      RelationType.parent => Icons.family_restroom,
      RelationType.spouse => Icons.favorite,
      RelationType.sibling => Icons.people,
      _ => Icons.link,
    };
  }

  // Adicionar método estático para mostrar diálogo
  static Future<RelationType?> show(BuildContext context) async {
    return showDialog<RelationType>(
      context: context,
      builder: (context) => RelationshipTypeDialog(
        onSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
  }
}

class CharacterDialogs {
  static Future<void> showEditDialog(
    BuildContext context,
    String characterId,
    String currentName,
    String currentDescription,
    Future<void> Function(String, {String? name, String? description}) onEdit,
  ) async {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);
    bool isSubmitting = false;

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Personagem'),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          StatefulBuilder(
            builder: (context, setState) => TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('O nome do personagem é obrigatório'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        await onEdit(
                          characterId,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Personagem atualizado com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao atualizar personagem: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showCreateDialog(
    BuildContext context,
    Function(String, String) onCreate,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isSubmitting = false;

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo Personagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Harry Potter',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: O menino que sobreviveu',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          StatefulBuilder(
            builder: (builderContext, setState) => TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(builderContext).showSnackBar(
                          const SnackBar(
                            content: Text('O nome do personagem é obrigatório'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        await onCreate(
                          nameController.text.trim(),
                          descriptionController.text.trim(),
                        );

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (builderContext.mounted) {
                          ScaffoldMessenger.of(builderContext).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao criar personagem: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar'),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showDeleteDialog(
    BuildContext context,
    CharacterModel character,
    Function(String) onDelete,
  ) async {
    bool isDeleting = false;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              title: const Text('Excluir Personagem'),
              content: Text('Deseja excluir o personagem ${character.name}?'),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.pop(builderContext),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);

                          try {
                            final confirmed = await showDialog<bool>(
                              context: builderContext,
                              builder: (confirmContext) => AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: const Text(
                                    'Esta ação não pode ser desfeita. Deseja continuar?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(confirmContext, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(confirmContext, true),
                                    child: const Text('Confirmar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed != true) {
                              setState(() => isDeleting = false);
                              return;
                            }

                            await onDelete(character.id);

                            if (builderContext.mounted) {
                              Navigator.of(builderContext).pop();
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Personagem excluído com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isDeleting = false);
                            if (builderContext.mounted) {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Erro ao excluir personagem: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showContextMenu(
    BuildContext context,
    CharacterModel character,
    Offset position,
    Future<void> Function(dynamic c) param3,
    Future<void> Function(dynamic c) param4,
    void Function(CharacterModel character) startConnection, {
    required Function(CharacterModel) onEdit,
    required Function(CharacterModel) onDelete,
    required Function(CharacterModel) onStartConnection,
  }) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          onTap: () => onEdit(character),
          child: const ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar'),
          ),
        ),
        PopupMenuItem(
          onTap: () => onDelete(character),
          child: const ListTile(
            leading: Icon(Icons.delete),
            title: Text('Excluir'),
          ),
        ),
        PopupMenuItem(
          onTap: () => onStartConnection(character),
          child: const ListTile(
            leading: Icon(Icons.link),
            title: Text('Conectar'),
          ),
        ),
        // Adicionar mais opções ao menu como:
        // - Duplicar personagem
        // - Agrupar personagens
        // - Desfazer última ação
      ],
    );
  }
}
