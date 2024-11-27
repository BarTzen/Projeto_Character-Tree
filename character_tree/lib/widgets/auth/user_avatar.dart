import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    // Usar os dados do UserModel para exibir o avatar
    final initial = user?.avatarInitial ?? 'U';
    final avatarColor = user?.avatarColor ?? Colors.grey;

    return IconButton(
      icon: CircleAvatar(
        backgroundColor: avatarColor,
        backgroundImage:
            user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
        child: user?.avatarUrl == null
            ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      onPressed: () => _showUserMenu(context, authViewModel),
    );
  }

  void _showUserMenu(BuildContext context, AuthViewModel authViewModel) {
    final user = authViewModel.currentUser;

    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          // Fundo escuro clicável para fechar
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black54),
          ),

          // Menu do usuário
          Positioned(
            top: kToolbarHeight + 10,
            right: 10,
            child: Card(
              elevation: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar grande
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: user?.avatarColor ?? Colors.grey,
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? Text(
                              user?.avatarInitial ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Nome do usuário
                    Text(
                      user?.name ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user?.email ?? 'Email não disponível',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Perfil'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sair'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _handleLogout(context, authViewModel);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthViewModel authViewModel) async {
    try {
      // Mostrar indicador de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Realizar logout
      await authViewModel.signOut();

      if (!context.mounted) return;

      // Fechar o loading
      Navigator.of(context).pop();

      // Aguardar o próximo frame para garantir que o estado foi atualizado
      await Future.microtask(() {});

      if (!context.mounted) return;

      // Navegar para a tela inicial e limpar a pilha
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        // Fechar o loading se estiver aberto
        Navigator.of(context).pop();

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: $e')),
        );
      }
    }
  }
}
