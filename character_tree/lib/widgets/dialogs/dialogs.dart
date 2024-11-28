import 'package:character_tree/models/character_model.dart';
import 'package:character_tree/utils/relation_type.dart';
import 'package:character_tree/viewmodel/character_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    Offset position, {
    required Function(CharacterModel) onEdit,
    required Function(CharacterModel) onDelete,
    required Function(CharacterModel) onStartConnection,
  }) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    return showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: const ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar'),
          ),
        ),
        PopupMenuItem(
          value: 'connect',
          child: const ListTile(
            leading: Icon(Icons.link),
            title: Text('Conectar'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: const ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      switch (value) {
        case 'edit':
          onEdit(character);
          break;
        case 'connect':
          onStartConnection(character);
          break;
        case 'delete':
          onDelete(character);
          break;
      }
    });
  }

  static Future<void> showProfileDialog(
    BuildContext context,
    CharacterModel character,
    List<CharacterModel> allCharacters,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar e Nome
              CircleAvatar(
                radius: 50,
                backgroundColor: getAvatarColor(character.name),
                child: Text(
                  character.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                character.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (character.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  character.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              // Conexões
              if (character.connections.isNotEmpty) ...[
                const Text(
                  'Conexões',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: character.connections.map((connectionId) {
                        final connectedChar = allCharacters.firstWhere(
                          (c) => c.id == connectionId,
                        );
                        final relationship =
                            character.relationships[connectionId] ?? 'other';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getAvatarColor(connectedChar.name),
                            child: Text(connectedChar.name[0].toUpperCase()),
                          ),
                          title: Text(connectedChar.name),
                          subtitle: Text(_getRelationshipText(relationship)),
                          trailing: IconButton(
                            icon: const Icon(Icons.link_off),
                            onPressed: () {
                              // Implementar remoção de conexão
                              Navigator.of(context).pop();
                              showDeleteConnectionDialog(
                                context,
                                character,
                                connectedChar,
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showEditDialog(
                        context,
                        character.id,
                        character.name,
                        character.description ?? '',
                        context.read<CharacterViewModel>().updateCharacter,
                      );
                    },
                    child: const Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showDeleteConnectionDialog(
    BuildContext context,
    CharacterModel source,
    CharacterModel target,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Conexão'),
        content: Text(
          'Deseja remover a conexão entre ${source.name} e ${target.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<CharacterViewModel>()
                  .disconnectCharacters(source.id, target.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  static Color getAvatarColor(String name) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[name.hashCode % colors.length];
  }

  static String _getRelationshipText(String relationship) {
    switch (relationship) {
      case 'parent':
        return 'Parente';
      case 'spouse':
        return 'Cônjuge';
      case 'sibling':
        return 'Irmão/Irmã';
      default:
        return 'Outro';
    }
  }
}
