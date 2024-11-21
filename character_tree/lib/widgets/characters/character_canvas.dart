import 'package:flutter/material.dart';
import '../../models/character_model.dart';

class ConnectionsPainter extends CustomPainter {
  final List<CharacterModel> characters;
  final CharacterModel? connectionStart;
  final CharacterModel? selectedCharacter;

  ConnectionsPainter({
    required this.characters,
    this.connectionStart,
    this.selectedCharacter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var char in characters) {
      if (char.connections.isNotEmpty) {
        for (var connectedId in char.connections) {
          var connected = characters.firstWhere((c) => c.id == connectedId);
          // Definir estilo da linha baseado no relacionamento
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
            default:
              paint.color = Colors.grey;
          }

          // Desenhar linha com curva suave
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
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) => true;
}

class CharacterNode extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onTap;

  const CharacterNode({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(character.name),
        ),
      ),
    );
  }
}

class CharacterCanvas extends StatefulWidget {
  final List<CharacterModel> characters;
  final Function(CharacterModel) onCharacterMoved;
  final Function(String, String, String) onCharacterConnected; // Atualizado para incluir relationshipType

  const CharacterCanvas({
    super.key,
    required this.characters,
    required this.onCharacterMoved,
    required this.onCharacterConnected,
  });

  @override
  State<CharacterCanvas> createState() => _CharacterCanvasState();
}

class _CharacterCanvasState extends State<CharacterCanvas> {
  CharacterModel? _selectedCharacter;
  CharacterModel? _connectionStart;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 2.0,
      child: Stack(
        children: [
          // Conexões entre personagens
          CustomPaint(
            painter: ConnectionsPainter(
              characters: widget.characters,
              connectionStart: _connectionStart,
              selectedCharacter: _selectedCharacter,
            ),
            size: Size.infinite,
          ),
          // Personagens arrastáveis
          ...widget.characters
              .map((character) => _buildDraggableCharacter(character)),
        ],
      ),
    );
  }

  Widget _buildDraggableCharacter(CharacterModel character) {
    return Positioned(
      left: character.position['x'] as double,
      top: character.position['y'] as double,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = character.position['x']! + details.delta.dx;
            final newY = character.position['y']! + details.delta.dy;
            widget.onCharacterMoved(character.updatePosition(newX, newY));
          });
        },
        child: CharacterNode(
          character: character,
          isSelected: character == _selectedCharacter,
          onTap: () => _handleCharacterTap(character),
        ),
      ),
    );
  }

  void _handleCharacterTap(CharacterModel character) {
    setState(() {
      if (_connectionStart == null) {
        _selectedCharacter = character;
        _connectionStart = character;
      } else {
        if (_connectionStart!.id != character.id) {
          widget.onCharacterConnected(
            _connectionStart!.id, 
            character.id,
            'default', // Tipo de relacionamento padrão
          );
        }
        _connectionStart = null;
        _selectedCharacter = null;
      }
    });
  }
}
