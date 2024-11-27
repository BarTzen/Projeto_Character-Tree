import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import 'character_card.dart';

class PositionedCharacterNode extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;

  const PositionedCharacterNode({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final x = (character.position['x'] ?? 100.0).toDouble();
    final y = (character.position['y'] ?? 100.0).toDouble();

    return Positioned(
      left: x,
      top: y,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.1 : 1.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (_) => onTap(),
          onPanStart: (_) => onDragStart(),
          onPanUpdate: onDragUpdate,
          onPanEnd: (_) => onDragEnd(),
          child: CharacterCard(
            character: character,
            isSelected: isSelected,
          ),
        ),
      ),
    );
  }
}
