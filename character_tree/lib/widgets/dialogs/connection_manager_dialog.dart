import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../../models/relationship_type.dart'
    as rel; // Usar alias para evitar conflito de nomes.

/// Diálogo para gerenciar conexões de um personagem.
class ConnectionManagerDialog extends StatelessWidget {
  final CharacterModel character; // Personagem atual.
  final List<CharacterModel>
      allCharacters; // Lista de todos os personagens disponíveis.
  final Function(String, String)
      onDisconnect; // Callback para desconectar personagens.

  const ConnectionManagerDialog({
    super.key,
    required this.character,
    required this.allCharacters,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Obtém conexões válidas do personagem.
      final connections = _getValidConnections();
      return _buildDialog(context, connections);
    } catch (e) {
      // Retorna um diálogo de erro se algo falhar.
      return _buildErrorDialog(context, e.toString());
    }
  }

  /// Filtra e retorna conexões válidas.
  List<CharacterModel> _getValidConnections() {
    return character.connections
        .map((id) => allCharacters.firstWhere(
              (c) => c.id == id,
              orElse: () =>
                  CharacterModel.empty(), // Tratamento para IDs inválidos.
            ))
        .where((c) => c.id.isNotEmpty) // Filtra personagens com IDs válidos.
        .toList();
  }

  /// Constrói o diálogo principal.
  Widget _buildDialog(BuildContext context, List<CharacterModel> connections) {
    if (connections.isEmpty) {
      // Retorna uma mensagem se não houver conexões.
      return AlertDialog(
        title: const Text('Gerenciar Conexões'),
        content: const Text('Nenhuma conexão encontrada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Gerenciar Conexões'),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 300), // Animação suave.
        child: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final connected = connections[index];
              final relationType =
                  character.relationships[connected.id] ?? 'other';

              return ListTile(
                title: Text(connected.name), // Nome do personagem conectado.
                subtitle: Text(rel.RelationType.values
                    .firstWhere((t) => t.name == relationType)
                    .description), // Descrição do relacionamento.
                trailing: IconButton(
                  icon: const Icon(Icons.link_off, color: Colors.red),
                  onPressed: () {
                    onDisconnect(
                        character.id, connected.id); // Executa desconexão.
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  /// Constrói um diálogo de erro.
  Widget _buildErrorDialog(BuildContext context, String errorMessage) {
    return AlertDialog(
      title: const Text('Erro'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
