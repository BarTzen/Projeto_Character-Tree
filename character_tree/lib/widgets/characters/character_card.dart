import 'package:flutter/material.dart';
import '../../models/character_model.dart';

/// Widget que representa um card para exibir informações de um personagem.
class CharacterCard extends StatelessWidget {
  final CharacterModel character; // Dados do personagem exibido no card.
  final bool isSelected; // Indica se o card está selecionado.
  static const double cardSize = 120.0; // Tamanho fixo do card.

  const CharacterCard({
    super.key,
    required this.character,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardSize, // Define a largura fixa do card.
      height: cardSize, // Define a altura fixa do card.
      child: Material(
        color: Colors.transparent, // Remove a cor padrão do Material.
        child: InkWell(
          borderRadius: BorderRadius.circular(8), // Aplica bordas arredondadas.
          onTap: () {
            // TODO: Adicionar ação ao toque no card, se necessário.
          },
          child: AnimatedContainer(
            // Anima mudanças visuais, como seleção.
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.white, // Cor de fundo baseada no estado.
              borderRadius: BorderRadius.circular(8), // Borda arredondada.
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey, // Cor da borda.
                width: 2, // Largura da borda.
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Usa o menor tamanho necessário.
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centraliza os filhos.
              children: [
                // Avatar circular exibindo a inicial do personagem.
                CircleAvatar(
                  radius: cardSize * 0.25, // Define o tamanho do avatar.
                  backgroundColor:
                      _getAvatarColor(character.name), // Cor dinâmica.
                  child: Text(
                    character.name[0].toUpperCase(), // Primeira letra do nome.
                    style: TextStyle(
                      color: Colors.white, // Cor do texto.
                      fontSize: cardSize * 0.2, // Tamanho proporcional ao card.
                      fontWeight: FontWeight.bold, // Texto em negrito.
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Espaçamento entre avatar e texto.
                // Nome do personagem.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    character.name, // Exibe o nome completo.
                    textAlign: TextAlign.center, // Centraliza o texto.
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // Texto em negrito.
                      fontSize: 14, // Tamanho fixo do texto.
                    ),
                    maxLines: 2, // Limita a duas linhas.
                    overflow: TextOverflow
                        .ellipsis, // Adiciona "..." se o texto exceder.
                  ),
                ),
                // Descrição do personagem, se disponível.
                if (character.description?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      character.description!, // Exibe a descrição.
                      textAlign: TextAlign.center, // Centraliza o texto.
                      style: TextStyle(
                        fontSize: 11, // Tamanho menor para a descrição.
                        color: Colors.grey[600], // Cor mais clara.
                      ),
                      maxLines: 1, // Limita a uma linha.
                      overflow: TextOverflow
                          .ellipsis, // Adiciona "..." se necessário.
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna uma cor baseada no nome do personagem.
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ]; // Paleta de cores pré-definida.
    final index =
        name.hashCode % colors.length; // Gera um índice único baseado no nome.
    return colors[index]; // Retorna a cor correspondente.
  }
}
