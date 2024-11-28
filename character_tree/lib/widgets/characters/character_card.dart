import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../../viewmodel/character_viewmodel.dart';
import 'package:provider/provider.dart';

/// Widget principal para exibição e interação com personagens
class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback? onTap;
  static const double cardSize = 200.0; // Aumentar tamanho do cartão

  const CharacterCard({
    super.key,
    required this.character,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<CharacterViewModel>();

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: cardSize,
        height: cardSize,
        decoration: _buildDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 8),
                  _buildCharacterInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() => BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            const BoxShadow(
              color: Colors.blue,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _buildAvatar() => Hero(
        tag: 'character_${character.id}',
        child: CircleAvatar(
          radius: cardSize * 0.25,
          backgroundColor: _getAvatarColor(character.name),
          child: Text(
            _getInitials(character.name),
            style: TextStyle(
              color: Colors.white,
              fontSize: cardSize * 0.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _buildCharacterInfo() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(
              character.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (character.description?.isNotEmpty ?? false)
              Text(
                character.description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );

  String _getInitials(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  Color _getAvatarColor(String name) {
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
}
