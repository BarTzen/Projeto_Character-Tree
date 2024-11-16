import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/genealogy/genealogy_viewmodel.dart';

class DashboardGenealogyScreen extends StatelessWidget {
  const DashboardGenealogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final genealogyViewModel = context.watch<GenealogyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de Genealogias'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createGenealogy');
                },
                child: Text('Criar Nova Genealogia'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Replace with actual count
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Genealogia $index'),
                      onTap: () {
                        Navigator.pushNamed(context, '/viewGenealogy');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
