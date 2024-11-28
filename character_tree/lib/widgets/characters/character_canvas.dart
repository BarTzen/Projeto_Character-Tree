import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../../viewmodel/character_viewmodel.dart';
import '../../widgets/characters/positioned_character_node.dart';

/// Pintor customizado para desenhar as conexões entre personagens.
class ConnectionsPainter extends CustomPainter {
  final List<CharacterModel> characters;
  final CharacterModel? connectionStart;
  final CharacterModel? selectedCharacter;
  final Offset? connectionEndPoint;
  final double animationValue;

  ConnectionsPainter({
    required this.characters,
    this.connectionStart,
    this.selectedCharacter,
    this.connectionEndPoint,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint connectionPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _drawExistingConnections(canvas, connectionPaint);
    _drawTemporaryConnection(canvas, connectionPaint);
  }

  void _drawExistingConnections(Canvas canvas, Paint connectionPaint) {
    for (var character in characters) {
      for (var connectedId in character.connections) {
        var connected = characters.firstWhere((c) => c.id == connectedId);
        connectionPaint.color =
            _getRelationshipColor(character.relationships[connectedId]);
        _drawConnection(
          canvas,
          Offset(character.position['x']!, character.position['y']!),
          Offset(connected.position['x']!, connected.position['y']!),
          connectionPaint,
        );
      }
    }
  }

  void _drawTemporaryConnection(Canvas canvas, Paint connectionPaint) {
    if (connectionStart != null && connectionEndPoint != null) {
      connectionPaint
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeWidth = 1.5;
      _drawConnection(
        canvas,
        Offset(
            connectionStart!.position['x']!, connectionStart!.position['y']!),
        connectionEndPoint!,
        connectionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionsPainter oldDelegate) {
    return characters != oldDelegate.characters ||
        connectionStart != oldDelegate.connectionStart ||
        selectedCharacter != oldDelegate.selectedCharacter ||
        connectionEndPoint != oldDelegate.connectionEndPoint ||
        animationValue != oldDelegate.animationValue;
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, Paint paint) {
    final Path path = Path();
    final controlPoint = _calculateControlPoint(start, end);
    final animatedEnd = _calculateAnimatedEnd(start, end);

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, animatedEnd.dx, animatedEnd.dy);

    if (selectedCharacter != null) {
      _drawGlowEffect(canvas, path, paint);
    }

    canvas.drawPath(path, paint);

    if (paint.color != Colors.grey.withOpacity(0.5)) {
      _drawArrow(canvas, animatedEnd, start, paint);
    }
  }

  Offset _calculateControlPoint(Offset start, Offset end) {
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final distance = (end - start).distance;
    return Offset(midX, midY - distance * 0.2);
  }

  Offset _calculateAnimatedEnd(Offset start, Offset end) {
    return Offset(
      start.dx + (end.dx - start.dx) * _smoothAnimation(animationValue),
      start.dy + (end.dy - start.dy) * _smoothAnimation(animationValue),
    );
  }

  double _smoothAnimation(double value) {
    return Curves.easeInOutCubic.transform(value);
  }

  void _drawGlowEffect(Canvas canvas, Path path, Paint paint) {
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, glowPaint);
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset start, Paint paint) {
    final angle = (tip - start).direction;
    const arrowSize = 10.0;

    final path = Path()
      ..moveTo(tip.dx - arrowSize * cos(angle - pi / 6),
          tip.dy - arrowSize * sin(angle - pi / 6))
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - arrowSize * cos(angle + pi / 6),
          tip.dy - arrowSize * sin(angle + pi / 6))
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  Color _getRelationshipColor(String? relationship) {
    switch (relationship) {
      case 'parent':
        return Colors.blue.shade400;
      case 'spouse':
        return Colors.red.shade400;
      case 'sibling':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}

/// Widget principal para o canvas dos personagens.
class CharacterCanvas extends StatelessWidget {
  final TransformationController transformationController;
  final List<CharacterModel> characters;
  final VoidCallback onBackgroundTap;
  final CharacterModel? selectedCharacter;
  final CharacterModel? connectionStart;
  final Offset? connectionEndPoint;
  final Function(CharacterModel) onCharacterTap;
  final Function(CharacterModel) onCharacterDragStart;
  final Function(CharacterModel, Offset) onCharacterDragUpdate;
  final Function(CharacterModel) onCharacterDragEnd;
  final Function(CharacterModel, Offset) onCharacterLongPress;
  final Function(ScaleUpdateDetails) onScaleUpdate;

  const CharacterCanvas({
    super.key,
    required this.transformationController,
    required this.characters,
    required this.onBackgroundTap,
    required this.selectedCharacter,
    required this.connectionStart,
    required this.connectionEndPoint,
    required this.onCharacterTap,
    required this.onCharacterDragStart,
    required this.onCharacterDragUpdate,
    required this.onCharacterDragEnd,
    required this.onCharacterLongPress,
    required this.onScaleUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGridBackground(),
        CustomPaint(
          painter: ConnectionsPainter(
            characters: characters,
            connectionStart: connectionStart,
            selectedCharacter: selectedCharacter,
            connectionEndPoint: connectionEndPoint,
          ),
          size: Size(
              CharacterViewModel.canvasWidth, CharacterViewModel.canvasHeight),
        ),
        ...characters.map((character) => PositionedCharacterNode(
              key: ValueKey(character.id),
              character: character,
              isSelected: selectedCharacter?.id == character.id,
              onTap: () => onCharacterTap(character),
              onDragStart: () => onCharacterDragStart(character),
              onDragUpdate: (character, offset) =>
                  onCharacterDragUpdate(character, offset),
              onDragEnd: () => onCharacterDragEnd(character),
              onLongPress: (offset) => onCharacterLongPress(character, offset),
            )),
      ],
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(),
      size: Size(
        CharacterViewModel.canvasWidth,
        CharacterViewModel.canvasHeight,
      ),
    );
  }

  static Widget buildZoomControls(CharacterViewModel viewModel) {
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
              onPressed: viewModel.centerCanvas,
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
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 100.0;

    for (var i = 0.0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (var i = 0.0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
