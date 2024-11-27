import 'package:character_tree/viewmodel/tree_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_type.dart';
import '../viewmodel/character_viewmodel.dart';
import '../widgets/auth/user_avatar.dart';
import '../widgets/characters/character_canvas.dart';
import '../widgets/characters/character_list_tile.dart';
import '../widgets/dialogs/relationship_type_dialog.dart';
import '../models/character_model.dart';

class TreeView extends StatefulWidget {
  final String treeId;

  const TreeView({super.key, required this.treeId});

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView>
    with SingleTickerProviderStateMixin {
  late TabController _viewModeController;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add form key

  @override
  void initState() {
    super.initState();
    _viewModeController = TabController(length: 2, vsync: this);

    // Garante que o treeId seja válido antes de carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.treeId.isEmpty) {
        _showMessage('ID da árvore inválido', isError: true);
        return;
      }

      // Primeiro seleciona a árvore
      context.read<TreeViewModel>().selectTree(widget.treeId);

      // Depois atualiza o CharacterViewModel
      final characterVM = context.read<CharacterViewModel>();
      characterVM.updateTreeId(widget.treeId);
      characterVM.loadCharacters(); // Força o carregamento inicial

      // Atualiza a árvore
      context.read<TreeViewModel>().refreshTree(widget.treeId);
    });
  }

  @override
  void dispose() {
    _viewModeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onCharacterOperation() async {
    await context.read<TreeViewModel>().refreshTree(widget.treeId);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showAddCharacterDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo Personagem'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'O nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
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
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => isSubmitting = true);

                      try {
                        final characterVM = Provider.of<CharacterViewModel>(
                            dialogContext,
                            listen: false);

                        await characterVM.createCharacter(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          context: dialogContext,
                        );

                        if (!mounted) return;

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        _showMessage('Personagem criado com sucesso!');

                        await _onCharacterOperation();
                      } catch (e) {
                        setState(() => isSubmitting = false);

                        if (!mounted) return;

                        _showMessage('Erro ao criar personagem: $e',
                            isError: true);
                      }
                    },
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Criar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCharacterDialog(
      String characterId, String currentName, String currentDescription) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);
    bool isSubmitting = false;

    showDialog(
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
                        if (!mounted) return;
                        _showMessage('O nome do personagem é obrigatório',
                            isError: true);
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        if (!mounted) return;
                        final characterVM = Provider.of<CharacterViewModel>(
                            dialogContext,
                            listen: false);

                        await characterVM.updateCharacter(
                          characterId,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );

                        if (!mounted) return;
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        _showMessage('Personagem atualizado com sucesso!');
                        await _onCharacterOperation();
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => isSubmitting = false);
                        _showMessage('Erro ao atualizar personagem: $e',
                            isError: true);
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

  void _showDeleteConfirmation(CharacterModel character) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            final characterVM = Provider.of<CharacterViewModel>(
              builderContext,
              listen: false,
            );

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

                            if (!builderContext.mounted) return;

                            if (confirmed != true) {
                              setState(() => isDeleting = false);
                              return;
                            }

                            await characterVM.deleteCharacter(character.id);

                            if (builderContext.mounted) {
                              Navigator.pop(builderContext);
                            }

                            if (!mounted) return;
                            await _onCharacterOperation();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Personagem excluído com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!builderContext.mounted) return;
                            setState(() => isDeleting = false);
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao excluir personagem: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Excluir',
                          style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Adicionado SafeArea para melhor layout
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'lib/assets/images/tree_logo_alt.png',
            fit: BoxFit.contain,
            height: 48,
          ),
          backgroundColor: Colors.blueGrey[100],
          actions: [
            const UserAvatar(), // Avatar do usuário
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              controller: _viewModeController,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.account_tree), text: 'Árvore'),
                Tab(icon: Icon(Icons.list), text: 'Lista'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _viewModeController,
          // Adicionar physics para controlar o comportamento do swipe
          physics: const ClampingScrollPhysics(),
          children: [
            _buildCanvasView(),
            _buildListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasView() {
    return Consumer<CharacterViewModel>(
      builder: (context, characterVM, child) {
        if (characterVM.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(characterVM.error!, textAlign: TextAlign.center),
                ElevatedButton(
                  onPressed: () async {
                    await characterVM.loadCharacters();
                    if (!mounted) return;
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (characterVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (characterVM.characters.isEmpty) {
          return const Center(
            child: Text('Nenhum personagem criado ainda'),
          );
        }

        return Container(
          color: Colors.grey[100], // Cor de fundo mais clara
          width: double.infinity,
          height: double.infinity,
          child: ClipRect(
            child: CharacterCanvas(
              characters: characterVM.characters,
              onCharacterMoved: (character) async {
                try {
                  final position = {
                    'x': character.position['x']!,
                    'y': character.position['y']!,
                  };
                  await characterVM.moveCharacter(
                      character, position['x']!, position['y']!);
                  if (mounted) {
                    await _onCharacterOperation();
                  }
                } catch (e) {
                  if (mounted) {
                    _showMessage('Erro ao mover personagem: $e', isError: true);
                  }
                }
              },
              onCharacterConnected: _handleCharacterConnection,
              onCharacterEdited: _showEditCharacterDialog,
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return Consumer<CharacterViewModel>(
      builder: (context, characterVM, child) {
        if (characterVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredCharacters =
            characterVM.filteredCharacters; // Usar lista filtrada apenas aqui

        return ListView.builder(
          itemCount: filteredCharacters.length,
          itemBuilder: (context, index) {
            final character = filteredCharacters[index];
            return CharacterListTile(
              character: character,
              onEdit: () => _showEditCharacterDialog(
                character.id,
                character.name,
                character.description ?? '',
              ),
              onDelete: () => _showDeleteConfirmation(character),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCharacterConnection(
      String sourceId, String targetId, String type) async {
    if (!mounted) return;

    try {
      final characterVM = context.read<CharacterViewModel>();
      final sourceChar = characterVM.characters.firstWhere(
        (c) => c.id == sourceId,
        orElse: () => throw Exception('Personagem não encontrado'),
      );

      if (sourceChar.connections.contains(targetId)) {
        throw Exception('Estes personagens já estão conectados');
      }

      // Usar BuildContext local para evitar problemas com Navigator
      final RelationType? result = await showDialog<RelationType>(
        context: context,
        barrierDismissible: true, // Permite fechar clicando fora
        builder: (BuildContext dialogContext) => RelationshipTypeDialog(
          onSelected: (type) => Navigator.of(dialogContext).pop(type),
        ),
      );

      if (!mounted || result == null) return;

      await characterVM.connectCharacters(
        sourceId: sourceId,
        targetId: targetId,
        relationshipType: result.name, // Passa o nome do relacionamento.
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personagens conectados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterCharacters(String query) {
    if (!mounted) return;
    context.read<CharacterViewModel>().searchCharacters(query);
  }
}
