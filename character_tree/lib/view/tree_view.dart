import 'package:character_tree/viewmodel/character_viewmodel.dart';
import 'package:character_tree/viewmodel/tree_viewmodel.dart';
import 'package:character_tree/widgets/auth/user_avatar.dart';
import 'package:character_tree/widgets/characters/character_canvas.dart';
import 'package:character_tree/widgets/characters/positioned_character_node.dart';
import 'package:character_tree/widgets/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:character_tree/models/character_model.dart'; // Adicionar este import
import 'package:logging/logging.dart';

class TreeView extends StatefulWidget {
  final String treeId;

  const TreeView({super.key, required this.treeId});

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView>
    with SingleTickerProviderStateMixin {
  final _log = Logger('TreeView');
  late TabController _viewModeController;
  final TextEditingController _searchController = TextEditingController();
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _viewModeController = TabController(length: 2, vsync: this);
    _transformationController = TransformationController();

    // Inicializa a transformação para o centro do canvas com zoom adequado
    _transformationController.value = Matrix4.identity()
      ..translate(-CharacterViewModel.canvasWidth / 3,
          -CharacterViewModel.canvasHeight / 3)
      ..scale(0.8);

    // Garanta que o treeId seja válido antes de carregar
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

      _centerCanvas();
    });
  }

  void _centerCanvas() {
    if (!mounted) return;

    final characterVM = context.read<CharacterViewModel>();
    if (characterVM.characters.isEmpty) return;

    // Calcula o centro baseado no primeiro personagem
    final firstChar = characterVM.characters.first;
    final centerX =
        firstChar.position['x']! - (CharacterViewModel.canvasWidth / 4);
    final centerY =
        firstChar.position['y']! - (CharacterViewModel.canvasHeight / 4);

    _transformationController.value = Matrix4.identity()
      ..translate(-centerX, -centerY)
      ..scale(0.5);

    characterVM.showAllCharacters();
  }

  @override
  void dispose() {
    _viewModeController.dispose();
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false, IconData? icon}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                context.read<CharacterViewModel>().loadCharacters();
              }
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      backgroundColor: Colors.blueGrey[100],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Image.asset(
        'lib/assets/images/tree_logo_alt.png',
        fit: BoxFit.contain,
        height: 48,
      ),
      backgroundColor: Colors.blueGrey[100],
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
        const UserAvatar(),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildViewModeSelector(),
        Expanded(
          child: Consumer<CharacterViewModel>(
            builder: (context, characterVM, child) {
              if (characterVM.error != null) {
                return _buildErrorView(characterVM.error!);
              }
              return TabBarView(
                controller: _viewModeController,
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildCanvasView(characterVM),
                  _buildListView(characterVM),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector() {
    return Builder(builder: (context) {
      return TabBar(
        controller: _viewModeController,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(
            icon: Icon(Icons.account_tree),
            text: 'Visualização em Árvore',
          ),
          Tab(
            icon: Icon(Icons.list),
            text: 'Lista de Personagens',
          ),
        ],
      );
    });
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        await CharacterDialogs.showCreateDialog(
          context,
          (name, description) async {
            await context.read<CharacterViewModel>().createCharacter(
                  name: name,
                  description: description,
                  context: context,
                );
            // Força o recarregamento dos personagens após a criação
            if (mounted) {
              await context.read<CharacterViewModel>().loadCharacters();
              _centerCanvas(); // Centraliza a visualização no novo personagem
            }
          },
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Novo Personagem'),
    );
  }

  // Novos métodos auxiliares
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Personagem'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Digite o nome do personagem',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            context.read<CharacterViewModel>().searchCharacters(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<CharacterViewModel>().searchCharacters('');
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasView(CharacterViewModel characterVM) {
    _log.fine(
        'Número de personagens: ${characterVM.filteredCharacters.length}');

    if (characterVM.error != null) return _buildErrorView(characterVM.error!);
    if (characterVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (characterVM.characters.isEmpty) return _buildEmptyState();

    return Container(
      color: Colors.blueGrey[50],
      child: GestureDetector(
        onTapDown: (_) => characterVM.selectCharacter(null),
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          maxScale: 2.0,
          constrained:
              false, // Importante: permite que o conteúdo seja maior que a tela
          child: Stack(
            children: [
              // Importante: Adicione um container transparente que cubra toda a área
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (_) => characterVM.selectCharacter(null),
                  child: Container(color: Colors.transparent),
                ),
              ),
              GestureDetector(
                onTap: () => characterVM.selectCharacter(null),
                child: Container(color: Colors.transparent),
              ),
              CustomPaint(
                painter: ConnectionsPainter(
                  characters: characterVM.filteredCharacters,
                  connectionStart: characterVM.connectionStart,
                  selectedCharacter: characterVM.selectedCharacter,
                  connectionEndPoint: characterVM.connectionEndPoint,
                ),
                size: Size(
                  CharacterViewModel.canvasWidth,
                  CharacterViewModel.canvasHeight,
                ),
              ),
              ...characterVM.filteredCharacters
                  .map((character) => PositionedCharacterNode(
                        key: ValueKey(character.id),
                        character: character,
                        isSelected:
                            characterVM.selectedCharacter?.id == character.id,
                        onTap: () => _handleCharacterTap(character),
                        onDragStart: () => HapticFeedback.selectionClick(),
                        onDragUpdate: (character, offset) =>
                            _handleCharacterMove(character, offset),
                        onDragEnd: () => HapticFeedback.lightImpact(),
                        onLongPress: (offset) =>
                            _handleLongPress(character, offset),
                      )),
              _buildZoomControls(characterVM),
              if (characterVM.connectionStart != null)
                _buildConnectionIndicator(characterVM.connectionStart!.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(String characterName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildZoomControls(CharacterViewModel viewModel) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: viewModel.zoomOut,
              iconSize: 20,
              tooltip: 'Diminuir',
            ),
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: () {
                viewModel.centerCanvas();
                _centerCanvas();
              },
              iconSize: 20,
              tooltip: 'Centralizar',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: viewModel.zoomIn,
              iconSize: 20,
              tooltip: 'Aumentar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(CharacterViewModel characterVM) {
    if (characterVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredCharacters = characterVM.filteredCharacters;

    if (filteredCharacters.isEmpty) {
      return const Center(
        child: Text('Nenhum personagem encontrado'),
      );
    }

    return ListView.builder(
      itemCount: filteredCharacters.length,
      itemBuilder: (context, index) {
        final character = filteredCharacters[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Hero(
              tag: 'character_${character.id}_avatar',
              child: CircleAvatar(
                backgroundColor: CharacterDialogs.getAvatarColor(
                    character.name), // Atualizado para usar o método público
                child: Text(
                  character.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            title: Text(
              character.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (character.description?.isNotEmpty ?? false)
                  Text(character.description!),
                if (character.connections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Conexões: ${character.connections.length}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () => _handleListItemTap(character),
            trailing: PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Visualizar'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Excluir', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _handleListItemTap(character);
                    break;
                  case 'edit':
                    _handleEdit(character);
                    break;
                  case 'delete':
                    _handleDelete(character);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Nenhum personagem criado ainda.\nUse o botão "+" para adicionar um personagem.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Adicionar estes métodos auxiliares
  void _handleCharacterMove(CharacterModel character, Offset position) async {
    final characterVM = context.read<CharacterViewModel>();
    try {
      // Adicionar validação de limites
      if (_isPositionValid(position)) {
        await characterVM.handleDragUpdate(character, position);
        HapticFeedback.mediumImpact();
      } else {
        _showMessage('Posição fora dos limites permitidos', isError: true);
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  bool _isPositionValid(Offset position) {
    return position.dx >= 0 &&
        position.dx <= CharacterViewModel.canvasWidth &&
        position.dy >= 0 &&
        position.dy <= CharacterViewModel.canvasHeight;
  }

  Future<void> _handleLongPress(
      CharacterModel character, Offset position) async {
    if (!mounted) return;
    await CharacterDialogs.showContextMenu(
      context,
      character,
      position,
      onEdit: _handleEdit,
      onDelete: _handleDelete,
      onStartConnection: _handleStartConnection,
    );
  }

  Future<void> _handleStartConnection(CharacterModel sourceCharacter) async {
    if (!mounted) return;

    final characterVM = context.read<CharacterViewModel>();
    final characters = characterVM.characters
        .where((c) => c.id != sourceCharacter.id)
        .toList();

    if (characters.isEmpty) {
      _showMessage('Não há outros personagens para conectar', isError: true);
      return;
    }

    // Primeiro diálogo - Seleção do personagem alvo
    final targetCharacter = await showDialog<CharacterModel?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Conectar com ${sourceCharacter.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: characters.length,
            itemBuilder: (_, index) => ListTile(
              leading: CircleAvatar(child: Text(characters[index].name[0])),
              title: Text(characters[index].name),
              onTap: () => Navigator.pop(dialogContext, characters[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (!mounted || targetCharacter == null) return;

    // Segundo diálogo - Seleção do tipo de relacionamento
    final type = await RelationshipTypeDialog.show(context);

    if (!mounted || type == null) return;

    try {
      await characterVM.connectCharacters(
        sourceId: sourceCharacter.id,
        targetId: targetCharacter.id,
        relationshipType: type.name,
      );
      if (mounted) {
        _showMessage('Conexão estabelecida com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Erro ao conectar personagens: $e', isError: true);
      }
    }
  }

  Future<void> _handleEdit(CharacterModel character) async {
    await CharacterDialogs.showEditDialog(
      context,
      character.id,
      character.name,
      character.description ?? '',
      context.read<CharacterViewModel>().updateCharacter,
    );
    _showMessage('Personagem atualizado com sucesso!');
  }

  Future<void> _handleDelete(CharacterModel character) async {
    await CharacterDialogs.showDeleteDialog(
      context,
      character,
      context.read<CharacterViewModel>().deleteCharacter,
    );
    _showMessage('Personagem excluído com sucesso!');
  }

  void _handleCharacterTap(CharacterModel character) {
    final characterVM = context.read<CharacterViewModel>();

    if (characterVM.isConnecting) {
      // Se estiver no modo de conexão e clicar em um personagem diferente
      if (characterVM.connectionStart?.id != character.id) {
        _completeConnection(character);
      }
    } else {
      // Apenas seleciona o personagem na visualização em árvore
      characterVM.selectCharacter(character);
    }
  }

  void _handleListItemTap(CharacterModel character) {
    // Método específico para a visualização em lista
    CharacterDialogs.showProfileDialog(
      context,
      character,
      context.read<CharacterViewModel>().characters,
    );
  }

  Future<void> _completeConnection(CharacterModel target) async {
    if (!mounted) return;
    final characterVM = context.read<CharacterViewModel>();

    try {
      // Mostra diálogo para selecionar tipo de relacionamento
      final type = await RelationshipTypeDialog.show(context);
      if (!mounted || type == null) {
        characterVM.cancelConnection();
        return;
      }

      await characterVM.completeConnection(target, type);
      _showMessage(
        'Conexão estabelecida com sucesso!',
        icon: Icons.check_circle,
      );
      HapticFeedback.heavyImpact();
    } catch (e) {
      _showMessage(e.toString(), isError: true);
      characterVM.cancelConnection();
    }
  }
}
