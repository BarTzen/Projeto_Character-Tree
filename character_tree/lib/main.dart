// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'services/cache_service.dart';
import 'services/firestore_service.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/tree_viewmodel.dart';
import 'view/auth_view.dart';
import 'view/home_view.dart';
import 'viewmodel/character_viewmodel.dart';

// Configuração do Logger
void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
      debugPrint('Stack trace: ${record.stackTrace}');
    }
  });
}

Future<void> main() async {
  final logger = Logger('Main');

  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogging();

    logger.info('Iniciando configuração do Firebase');

    // Verifica se o Firebase já foi inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      logger.info('Firebase inicializado com sucesso');
    } else {
      logger.warning('Firebase já foi inicializado anteriormente.');
    }

    runApp(const MyAppWithProviders());
  } catch (e, stackTrace) {
    logger.severe('Erro ao inicializar o aplicativo', e, stackTrace);
  }
}

class MyAppWithProviders extends StatelessWidget {
  const MyAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger('MyAppWithProviders');
    logger.fine('Inicializando providers');

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.severe(
              'Erro ao inicializar SharedPreferences', snapshot.error);
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child:
                    Text('Erro ao inicializar o aplicativo: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => AuthService(),
            ),
            Provider<CacheService>(
              create: (_) => CacheService(snapshot.data!),
            ),
            Provider<FirestoreService>(
              create: (_) => FirestoreService(),
            ),
            ChangeNotifierProvider<AuthViewModel>(
              create: (context) => AuthViewModel(
                authService: context.read<AuthService>(),
                cacheService: context.read<CacheService>(),
              ),
            ),
            ChangeNotifierProvider<TreeViewModel>(
              create: (context) => TreeViewModel(
                firestoreService: context.read<FirestoreService>(),
              ),
            ),
            ChangeNotifierProxyProvider<TreeViewModel, CharacterViewModel>(
              create: (context) => CharacterViewModel(
                firestoreService: context.read<FirestoreService>(),
                treeId: '',
              ),
              update: (context, treeVM, previousCharacterVM) =>
                  CharacterViewModel(
                firestoreService: context.read<FirestoreService>(),
                treeId: treeVM.selectedTreeId ?? '',
              ),
            ),
          ],
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger('MyApp');
    logger.fine('Construindo MaterialApp');

    return MaterialApp(
      title: 'Character Tree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        Widget page;
        final authVM = context.read<AuthViewModel>();

        if (authVM.status == AuthStatus.loading) {
          page = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          page = authVM.isAuthenticated ? const HomeView() : const AuthView();
        }

        return MaterialPageRoute(
          builder: (_) => ErrorHandler(
            logger: logger,
            child: page,
          ),
        );
      },
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) => ErrorHandler(
          logger: logger,
          child: authVM.isAuthenticated ? const HomeView() : const AuthView(),
        ),
      ),
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;
  final Logger logger;

  const ErrorHandler({
    super.key,
    required this.child,
    required this.logger,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stack) {
          logger.severe('Erro na UI', e, stack);
          return _buildErrorWidget(context, e.toString());
        }
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Ocorreu um erro inesperado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Voltar para o início'),
            ),
          ],
        ),
      ),
    );
  }
}
