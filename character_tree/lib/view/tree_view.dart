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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => CharacterDialogs.showCreateDialog(
        context,
        (name, description) => context
            .read<CharacterViewModel>()
            .createCharacter(
                name: name, description: description, context: context),
      ),
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
                        onTap: () {
                          _handleCharacterSelect(character);
                          HapticFeedback.selectionClick();
                        },
                        onDragStart: () => _handleConnectionStart(character),
                        onDragUpdate: (character, offset) =>
                            _handleCharacterMove(character, offset),
                        onDragEnd: () {
                          if (characterVM.connectionStart != null &&
                              characterVM.selectedCharacter != null) {
                            _handleConnectionEnd(
                              characterVM.connectionStart!.id,
                              characterVM.selectedCharacter!.id,
                            );
                          }
                          characterVM.updateConnectionEndPoint(null);
                        },
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
        return ListTile(
          tileColor: Colors.grey[100],
          leading: CircleAvatar(
            child: Text(character.name[0].toUpperCase()),
          ),
          title: Text(character.name),
          subtitle: Text(character.description ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => CharacterDialogs.showEditDialog(
                  context,
                  character.id,
                  character.name,
                  character.description ?? '',
                  characterVM.updateCharacter,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => CharacterDialogs.showDeleteDialog(
                  context,
                  character,
                  characterVM.deleteCharacter,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Nenhum personagem criado ainda'),
          ElevatedButton.icon(
            onPressed: () => CharacterDialogs.showCreateDialog(
              context,
              (name, description) =>
                  context.read<CharacterViewModel>().createCharacter(
                        name: name,
                        description: description,
                        context: context,
                      ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Criar primeiro personagem'),
          ),
        ],
      ),
    );
  }

  // Adicionar estes métodos auxiliares
  void _handleCharacterMove(CharacterModel character, Offset position) async {
    final characterVM = context.read<CharacterViewModel>();
    try {
      // Adicionar validação de limites
      if (_isPositionValid(position)) {
        await characterVM.handleCharacterMove(character, position);
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

  void _handleConnectionStart(CharacterModel character) {
    final characterVM = context.read<CharacterViewModel>();
    characterVM.startConnection(character);
    HapticFeedback.mediumImpact();
    _showMessage(
      'Iniciando conexão com ${character.name}...',
      icon: Icons.arrow_forward,
    );
  }

  Future<void> _handleConnectionEnd(String sourceId, String targetId) async {
    if (!mounted) return;
    final characterVM = context.read<CharacterViewModel>();

    try {
      final type = await RelationshipTypeDialog.show(context);
      if (!mounted) return;

      if (type != null) {
        await characterVM.handleCharacterConnection(sourceId, targetId, type);
        HapticFeedback.heavyImpact();
        _showMessage('Conexão estabelecida com sucesso!');
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      characterVM.cancelConnection();
    }
  }

  Future<void> _handleLongPress(
      CharacterModel character, Offset position) async {
    if (!mounted) return;
    await CharacterDialogs.showContextMenu(
      context,
      character,
      position,
      (c) => _handleEdit(c),
      (c) => _handleDelete(c),
      context.read<CharacterViewModel>().startConnection,
      onEdit: (c) => _handleEdit(c),
      onDelete: (c) => _handleDelete(c),
      onStartConnection: (c) => _handleConnectionStart(c),
    );
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

  void _handleCharacterSelect(CharacterModel character) {
    final characterVM = context.read<CharacterViewModel>();
    if (characterVM.selectedCharacter?.id == character.id) {
      // Desseleciona se clicar no mesmo personagem
      characterVM.selectCharacter(null);
    } else {
      // Seleciona o novo personagem
      characterVM.selectCharacter(character);
    }
    HapticFeedback.selectionClick();
  }
}
