import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/tree_viewmodel.dart';
import '../widgets/auth/user_avatar.dart';
import '../widgets/trees/create_tree_dialog.dart';
import '../widgets/trees/tree_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.currentUser != null) {
        context.read<TreeViewModel>().loadUserTrees(authVM.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/tree_logo_alt.png',
          fit: BoxFit.contain,
          height: 48,
        ),
        backgroundColor: Colors.blueGrey[100],
        actions: const [
          UserAvatar(),
        ],
      ),
      body: Container(
        color: Colors.blueGrey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showCreateTreeDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Nova Árvore Literária'),
              ),
            ),
            Expanded(
              child: Consumer<TreeViewModel>(
                builder: (context, treeVM, child) {
                  if (treeVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (treeVM.trees.isEmpty) {
                    return const Center(
                      child: Text('Você ainda não tem árvores literárias'),
                    );
                  }

                  return ListView.builder(
                    itemCount: treeVM.trees.length,
                    itemBuilder: (context, index) {
                      final tree = treeVM.trees[index];
                      return TreeCard(tree: tree);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTreeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTreeDialog(),
    );
  }
}
