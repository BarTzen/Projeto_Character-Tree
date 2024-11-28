import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/character_model.dart';
import 'character_card.dart';

class PositionedCharacterNode extends StatefulWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback? onTap;
  final Function(Offset) onLongPress;
  final VoidCallback onDragStart;
  final Function(CharacterModel, Offset)? onDragUpdate;
  final VoidCallback? onDragEnd;

  const PositionedCharacterNode({
    super.key,
    required this.character,
    this.isSelected = false,
    this.onTap,
    required this.onLongPress,
    required this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  PositionedCharacterNodeState createState() => PositionedCharacterNodeState();
}

class PositionedCharacterNodeState extends State<PositionedCharacterNode>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _shakeController;
  late Offset _startOffset;
  late Offset _currentPosition;
  static const double _dampingFactor = 0.3; // Ajustado de 0.5 para 0.3

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _currentPosition = Offset(
      widget.character.position['x']!,
      widget.character.position['y']!,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentPosition.dx,
      top: _currentPosition.dy,
      child: GestureDetector(
        onTapDown: (_) => widget.onTap?.call(),
        onLongPress: () => widget.onLongPress(_currentPosition),
        onPanStart: _handleDragStart,
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        child: AnimatedScale(
          scale: _isDragging
              ? 1.05
              : widget.isSelected
                  ? 1.1
                  : 1.0,
          duration: const Duration(milliseconds: 150),
          child: CharacterCard(
            character: widget.character,
            isSelected: widget.isSelected,
          ),
        ),
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _startOffset = details.globalPosition;
      _currentPosition = Offset(
        widget.character.position['x']!,
        widget.character.position['y']!,
      );
    });
    widget.onDragStart();
    HapticFeedback.selectionClick();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final delta = details.globalPosition - _startOffset;
    setState(() {
      _currentPosition = Offset(
        widget.character.position['x']! + delta.dx * _dampingFactor,
        widget.character.position['y']! + delta.dy * _dampingFactor,
      );
    });

    widget.onDragUpdate?.call(
      widget.character,
      _currentPosition,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    setState(() => _isDragging = false);
    widget.onDragEnd?.call();
    HapticFeedback.lightImpact();
  }
}
