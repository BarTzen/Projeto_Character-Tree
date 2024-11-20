import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/auth/user_viewmodel.dart';
import '../widgets/user_avatar.dart';

class GenealogyScreen extends StatelessWidget {
  const GenealogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    userViewModel.loadUserData();

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[100],
        title: Image.asset(
          'lib/assets/images/tree_logo_alt.png',
          height: 40,
        ),
        actions: [
          const UserAvatar(),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTapDown: (details) {
            // Logic to add a new character node at the tapped position
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: GenealogyPainter(),
          ),
        ),
      ),
    );
  }
}

class GenealogyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Logic to draw nodes and connecting lines
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
