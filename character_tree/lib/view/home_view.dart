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
    // Delay para garantir que o context está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrees();
    });
  }

  Future<void> _loadTrees() async {
    final authVM = context.read<AuthViewModel>();
    final treeVM = context.read<TreeViewModel>();

    if (authVM.currentUser != null) {
      try {
        await treeVM.loadUserTrees(authVM.currentUser!.id);
      } catch (e) {
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erro ao carregar árvores. Por favor, tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
              child: _buildTreeList(),
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

  Widget _buildTreeList() {
    return Consumer<TreeViewModel>(
      builder: (context, treeVM, child) {
        if (treeVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (treeVM.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Não foi possível carregar suas árvores'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTrees,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (treeVM.trees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Você ainda não tem árvores literárias'),
                const SizedBox(height: 16),
                const Text(
                  'Crie sua primeira árvore usando o botão acima',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: treeVM.trees.length,
          itemBuilder: (context, index) => TreeCard(tree: treeVM.trees[index]),
        );
      },
    );
  }
}
