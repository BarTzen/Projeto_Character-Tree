import 'package:character_tree/widgets/characters/character_card.dart';
import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../dialogs/relationship_type_dialog.dart';
import 'positioned_character_node.dart';

/// Pintor customizado para desenhar as conexões entre personagens.
class ConnectionsPainter extends CustomPainter {
  final List<CharacterModel> characters; // Lista de personagens.
  final CharacterModel? connectionStart; // Personagem que iniciou a conexão.
  final CharacterModel? selectedCharacter; // Personagem selecionado.
  final Offset? connectionEndPoint; // Ponto final da conexão.

  ConnectionsPainter({
    required this.characters,
    this.connectionStart,
    this.selectedCharacter,
    this.connectionEndPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var char in characters) {
      if (char.connections.isNotEmpty) {
        for (var connectedId in char.connections) {
          var connected = characters.firstWhere((c) => c.id == connectedId);

          // Definir a cor da linha com base no relacionamento.
          final paint = Paint()
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

          final relationship = char.relationships[connectedId];
          switch (relationship) {
            case 'parent':
              paint.color = Colors.blue;
              break;
            case 'spouse':
              paint.color = Colors.red;
              break;
            case 'sibling':
              paint.color = Colors.green;
              break;
            default:
              paint.color = Colors.grey;
          }

          // Desenha uma linha curva suave entre os personagens.
          final path = Path();
          final start = Offset(char.position['x']!, char.position['y']!);
          final end =
              Offset(connected.position['x']!, connected.position['y']!);

          path.moveTo(start.dx, start.dy);
          path.quadraticBezierTo(
            (start.dx + end.dx) / 2,
            (start.dy + end.dy) / 2,
            end.dx,
            end.dy,
          );

          canvas.drawPath(path, paint);
        }
      }
    }

    // Desenha uma linha temporária enquanto o usuário está criando uma conexão.
    if (connectionStart != null && connectionEndPoint != null) {
      final paint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final start = Offset(
          connectionStart!.position['x']!, connectionStart!.position['y']!);
      final end = connectionEndPoint!;

      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
        end.dx,
        end.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return characters != oldDelegate.characters ||
        connectionStart != oldDelegate.connectionStart ||
        selectedCharacter != oldDelegate.selectedCharacter ||
        connectionEndPoint != oldDelegate.connectionEndPoint;
  }
}

/// Widget que exibe os personagens e permite manipulação interativa.
class CharacterCanvas extends StatefulWidget {
  final List<CharacterModel> characters;
  final Function(CharacterModel) onCharacterMoved; // Callback de movimento.
  final Function(String, String, String)
      onCharacterConnected; // Conectar personagens.
  final Function(String, String, String)
      onCharacterEdited; // Editar personagens.

  const CharacterCanvas({
    super.key,
    required this.characters,
    required this.onCharacterMoved,
    required this.onCharacterConnected,
    required this.onCharacterEdited,
  });

  @override
  State<CharacterCanvas> createState() => _CharacterCanvasState();
}

class _CharacterCanvasState extends State<CharacterCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  static const Size canvasSize = Size(3000, 2000); // Tamanho do canvas.

  CharacterModel? _selectedCharacter; // Personagem selecionado.
  CharacterModel? _connectionStart; // Personagem inicial da conexão.
  Offset? _connectionEndPoint; // Ponto final da conexão.

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: true,
      minScale: 0.5,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.all(50),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Desenho do grid no fundo.
            RepaintBoundary(
              child: CustomPaint(
                painter: GridPainter(),
                size: const Size(3000, 2000),
              ),
            ),

            // Desenho das conexões entre personagens.
            RepaintBoundary(
              child: CustomPaint(
                painter: ConnectionsPainter(
                  characters: widget.characters,
                  connectionStart: _connectionStart,
                  connectionEndPoint: _connectionEndPoint,
                  selectedCharacter: _selectedCharacter,
                ),
                size: const Size(3000, 2000),
              ),
            ),

            // Personagens na tela.
            ...widget.characters.map(
              (character) => PositionedCharacterNode(
                key: ValueKey(character.id),
                character: character,
                isSelected: character == _selectedCharacter,
                onTap: () => _handleCharacterTap(character),
                onDragStart: () => _handleDragStart(character),
                onDragUpdate: (details) =>
                    _handleDragUpdate(character, details),
                onDragEnd: () => _handleDragEnd(character),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói os botões de controle de zoom e centralização.
  Widget _buildControls() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            heroTag: 'center',
            mini: true,
            onPressed: _centerView,
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }

  // Métodos para controle de zoom e centralização.
  void _zoomIn() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale < 2.5) {
      _transformationController.value = Matrix4.identity()..scale(scale + 0.2);
    }
  }

  void _zoomOut() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale > 0.5) {
      _transformationController.value = Matrix4.identity()..scale(scale - 0.2);
    }
  }

  void _centerView() {
    _transformationController.value = Matrix4.identity();
  }

  void _handleDragStart(CharacterModel character) {
    setState(() {
      _selectedCharacter = character;
    });
  }

  void _handleDragUpdate(CharacterModel character, DragUpdateDetails details) {
    final Matrix4 transform = _transformationController.value;
    final double scale = transform.getMaxScaleOnAxis();

    final newX = (character.position['x']! + details.delta.dx / scale)
        .clamp(0.0, canvasSize.width - CharacterCard.cardSize);
    final newY = (character.position['y']! + details.delta.dy / scale)
        .clamp(0.0, canvasSize.height - CharacterCard.cardSize);

    if (!_checkCollision(character.id, newX, newY)) {
      widget.onCharacterMoved(character.updatePosition(newX, newY));
    }
  }

  bool _checkCollision(String currentId, double x, double y) {
    const minDistance = CharacterCard.cardSize * 1.2;
    return widget.characters.any((other) =>
        other.id != currentId &&
        (other.position['x']! - x).abs() < minDistance &&
        (other.position['y']! - y).abs() < minDistance);
  }

  void _handleDragEnd(CharacterModel character) {
    setState(() {
      _connectionEndPoint = null;
      if (_connectionStart != null && _selectedCharacter != _connectionStart) {
        widget.onCharacterConnected(
          _connectionStart!.id,
          character.id,
          'default',
        );
        _connectionStart = null;
      }
      _selectedCharacter = null;
    });
  }

  void _handleCharacterTap(CharacterModel character) {
    setState(() {
      if (_connectionStart == null) {
        _selectedCharacter = character;
        _connectionStart = character;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Selecione outro personagem para conectar ou toque fora para cancelar'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        if (_connectionStart!.id != character.id) {
          _showConnectionTypeDialog(_connectionStart!, character);
        }
        _cancelConnection();
      }
    });
  }

  void _cancelConnection() {
    setState(() {
      _connectionStart = null;
      _selectedCharacter = null;
    });
  }

  // Exibe o diálogo para selecionar o tipo de conexão.
  void _showConnectionTypeDialog(CharacterModel start, CharacterModel end) {
    showDialog(
      context: context,
      builder: (context) {
        return RelationshipTypeDialog(
          onSelected: (relation) {
            widget.onCharacterConnected(start.id, end.id,
                relation.name); // Passa o nome do relacionamento.
          },
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 100) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
