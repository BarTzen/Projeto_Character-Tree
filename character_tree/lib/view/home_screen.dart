import 'package:character_tree/models/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/user_avatar.dart';
import '../../viewmodel/auth/user_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    userViewModel.loadUserData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().sair();  // Chama o método sair() do seu AuthService
              Navigator.pushReplacementNamed(context, '/'); // Navega para a tela de login
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const UserAvatar(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/genealogy');
              },
              child: const Text('Criar Genealogia'),
            ),
          ],
        ),
      ),
    );
  }
}
