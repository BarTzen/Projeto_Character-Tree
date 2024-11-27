import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../viewmodel/character_viewmodel.dart';
import '../dialogs/connection_manager_dialog.dart';

/// Widget que fornece ações rápidas para um personagem.
/// Inclui opções como editar, conectar, gerenciar conexões e excluir.
class CharacterQuickActions extends StatelessWidget {
  final CharacterModel character; // Modelo de dados do personagem.
  final VoidCallback onEdit; // Callback para ação de edição.
  final VoidCallback onDelete; // Callback para ação de exclusão.
  final VoidCallback onConnect; // Callback para ação de conexão.

  const CharacterQuickActions({
    super.key,
    required this.character,
    required this.onEdit,
    required this.onDelete,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    // Obtém o ViewModel de personagens.
    final characterVM = Provider.of<CharacterViewModel>(context, listen: false);

    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 16), // Margem interna vertical.
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // O layout ocupa o menor espaço possível.
        children: [
          // Opção para editar o personagem.
          ListTile(
            leading: const Icon(Icons.edit), // Ícone de edição.
            title: const Text('Editar'), // Título da ação.
            onTap: () {
              Navigator.pop(context); // Fecha o diálogo.
              onEdit(); // Executa a callback de edição.
            },
          ),
          // Condicional para exibir o gerenciamento de conexões.
          if (character.connections.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.link_off), // Ícone de desconectar.
              title: const Text('Gerenciar Conexões'), // Título da ação.
              onTap: () {
                Navigator.pop(context); // Fecha o diálogo.
                // Exibe o diálogo de gerenciamento de conexões.
                showDialog(
                  context: context,
                  builder: (context) => ConnectionManagerDialog(
                    character: character, // Personagem atual.
                    allCharacters:
                        characterVM.characters, // Todos os personagens.
                    // Callback para desconectar personagens.
                    onDisconnect: (sourceId, targetId) async {
                      try {
                        // Tenta desconectar os personagens.
                        await characterVM.disconnectCharacters(
                            sourceId, targetId);
                        if (!context.mounted) return;
                        // Exibe sucesso na desconexão.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Conexão removida com sucesso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        // Exibe erro ao remover conexão.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao remover conexão: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          // Opção para conectar o personagem a outro.
          ListTile(
            leading: const Icon(Icons.link), // Ícone de conectar.
            title: const Text('Conectar'), // Título da ação.
            onTap: () {
              Navigator.pop(context); // Fecha o diálogo.
              onConnect(); // Executa a callback de conexão.
            },
          ),
          // Opção para excluir o personagem.
          ListTile(
            leading: const Icon(Icons.delete,
                color: Colors.red), // Ícone de exclusão.
            title: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red), // Texto em vermelho.
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o diálogo.
              onDelete(); // Executa a callback de exclusão.
            },
          ),
        ],
      ),
    );
  }
}
