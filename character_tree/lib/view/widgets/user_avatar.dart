import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth/user_viewmodel.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: userViewModel.photoURL != null
              ? NetworkImage(userViewModel.photoURL!)
              : null,
          child: userViewModel.photoURL == null
              ? Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          userViewModel.displayName ?? 'Usuário',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userViewModel.email ?? 'Email não disponível',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
