import 'package:character_tree/widgets/characters/character_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/character_model.dart';

/// Widget para posicionar e manipular um nó de personagem.
class PositionedCharacterNode extends StatefulWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDragStart;
  final Function(CharacterModel, Offset)? onDragUpdate;
  final VoidCallback? onDragEnd;
  final Function(Offset) onLongPress;

  const PositionedCharacterNode({
    super.key,
    required this.character,
    this.isSelected = false,
    this.onTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    required this.onLongPress,
  });

  @override
  PositionedCharacterNodeState createState() => PositionedCharacterNodeState();
}

class PositionedCharacterNodeState extends State<PositionedCharacterNode>
    with SingleTickerProviderStateMixin {
  bool _isInteracting = false;
  static const double minDragDelta = 5.0;
  bool _isDragging = false;
  Offset? _lastPosition;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: widget.character.position['x']?.toDouble() ?? 100.0,
      top: widget.character.position['y']?.toDouble() ?? 100.0,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            setState(() => _isInteracting = true);
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            setState(() => _isInteracting = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isInteracting = false),
          onLongPressStart: (details) {
            setState(() => _isInteracting = true);
            HapticFeedback.heavyImpact();
            widget.onLongPress(details.globalPosition);
          },
          onLongPressEnd: (_) => setState(() => _isInteracting = false),
          onPanStart: (details) {
            setState(() {
              _isDragging = true;
              _lastPosition = details.globalPosition;
            });
            widget.onDragStart?.call();
            HapticFeedback.mediumImpact();
          },
          onPanUpdate: (details) {
            if (!_isDragging || _lastPosition == null) return;

            final delta = details.globalPosition - _lastPosition!;
            if (delta.distance < minDragDelta) return;

            _lastPosition = details.globalPosition;

            if (widget.onDragUpdate != null) {
              final newPosition = Offset(
                (widget.character.position['x'] ?? 0.0) + delta.dx,
                (widget.character.position['y'] ?? 0.0) + delta.dy,
              );
              widget.onDragUpdate!(widget.character, newPosition);
            }
          },
          onPanEnd: (details) {
            setState(() {
              _isDragging = false;
              _lastPosition = null;
            });
            widget.onDragEnd?.call();
            HapticFeedback.lightImpact();
          },
          child: AnimatedScale(
            scale: _getCardScale(),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: CharacterCard(
              character: widget.character,
              isSelected: widget.isSelected,
              onTap: widget.onTap,
            ),
          ),
        ),
      ),
    );
  }

  double _getCardScale() {
    if (widget.isSelected) return 1.1;
    if (_isDragging) return 1.05;
    if (_isInteracting) return 1.02;
    return 1.0;
  }
}
