import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth/user_viewmodel.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final displayName = userViewModel.displayName ?? userViewModel.email ?? 'U';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return IconButton(
      icon: CircleAvatar(
        child: Text(
          initial,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  top: kToolbarHeight + 10,
                  right: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(
                              initial,
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userViewModel.displayName ?? 'Usuário',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userViewModel.email ?? 'Email não disponível',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              await userViewModel.logout();
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
