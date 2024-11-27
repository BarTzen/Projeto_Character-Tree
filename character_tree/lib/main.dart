import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint(
          '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        debugPrint('Error: ${record.error}');
        debugPrint('Stack trace: ${record.stackTrace}');
      }
    }
  });
}

// Add late variable to store the box
late final Box charactersBox;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();

  try {
    // Inicializar Hive
    await Hive.initFlutter();
    charactersBox = await Hive.openBox('characters');

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    Logger('Init').severe('Erro na inicialização', e, stack);
    rethrow;
  }
}

Future<void> main() async {
  try {
    await initializeApp();
    runApp(const MyAppWithProviders());
  } catch (e, stack) {
    Logger('Main').severe('Erro fatal ao inicializar o aplicativo', e, stack);
    // Mostra uma tela de erro genérica
    runApp(MaterialApp(home: ErrorScreen(error: e.toString())));
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro Fatal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
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
                treeId: '', // Inicializa com string vazia
                localCache: charactersBox,
              ),
              update: (context, treeVM, previousCharacterVM) {
                // Só atualiza se houver uma árvore selecionada válida
                if (treeVM.selectedTreeId?.isNotEmpty ?? false) {
                  final vm = previousCharacterVM ??
                      CharacterViewModel(
                        firestoreService: context.read<FirestoreService>(),
                        treeId: treeVM.selectedTreeId!,
                        localCache: charactersBox,
                      );

                  // Atualiza o treeId apenas se for diferente
                  if (vm.treeId != treeVM.selectedTreeId) {
                    vm.updateTreeId(treeVM.selectedTreeId!);
                  }
                  return vm;
                }
                return previousCharacterVM ??
                    CharacterViewModel(
                      firestoreService: context.read<FirestoreService>(),
                      treeId: '',
                      localCache: charactersBox,
                    );
              },
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
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          if (authVM.status == AuthStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return ErrorHandler(
            logger: logger,
            child: authVM.isAuthenticated ? const HomeView() : const AuthView(),
          );
        },
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

  Widget _buildErrorWidget(BuildContext context, String mensagemErro) {
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
                  mensagemErro,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: () => _handleRetry(context),
              child: const Text('Tentar novamente'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _handleReset(context),
              child: const Text('Voltar para o início'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => child),
      );
    } catch (e, stack) {
      logger.warning('Erro ao tentar novamente', e, stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao tentar novamente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleReset(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}
