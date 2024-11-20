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
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: Colors.blueGrey[100],
        title: Image.asset(
          'lib/assets/images/tree_logo_alt.png',
          height: 40,
        ),
        actions: [
          const UserAvatar(),
=======
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().sair();  // Chama o método sair() do seu AuthService
              Navigator.pushReplacementNamed(context, '/'); // Navega para a tela de login
            },
          ),
>>>>>>> da518837ce14aed5401c35482d3f6047c56748bb
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo ao Character Tree!'),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String treeName = '';
                    return AlertDialog(
                      title: const Text('Criar Nova Genealogia'),
                      content: TextField(
                        onChanged: (value) {
                          treeName = value;
                        },
                        decoration: const InputDecoration(
                            hintText: 'Nome da Genealogia'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (treeName.isNotEmpty) {
                              // Logic to create a new genealogy tree
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/genealogy');
                            }
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Criar Nova Genealogia'),
            ),
          ],
        ),
      ),
    );
  }
}
