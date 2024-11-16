import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

import 'view/auth/login_screen.dart';
import 'view/auth/register_screen.dart';
import 'view/genealogy/create_genealogy_screen.dart';
import 'viewmodel/auth/login_viewmodel.dart';
import 'viewmodel/auth/register_viewmodel.dart';
import 'viewmodel/genealogy/genealogy_viewmodel.dart';
import 'view/home/home_screen.dart';
import 'view/genealogy/genealogy_screen.dart';
import 'viewmodel/auth/user_viewmodel.dart';

// Configuração do Logger
void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
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
    if (kDebugMode) {
      debugPrint('Erro fatal ao inicializar o aplicativo: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

class MyAppWithProviders extends StatelessWidget {
  const MyAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger('MyAppWithProviders');
    logger.fine('Inicializando providers');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            logger.fine('Criando LoginViewModel');
            return LoginViewModel();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            logger.fine('Criando RegisterViewModel');
            return RegisterViewModel();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            logger.fine('Criando GenealogyViewModel');
            return GenealogyViewModel();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            logger.fine('Criando UserViewModel');
            return UserViewModel();
          },
        ),
      ],
      child: const MyApp(),
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
      initialRoute: '/',
      routes: {
        '/': (context) {
          logger.fine(' Navegando para LoginScreen');
          return const LoginScreen();
        },
        '/register': (context) {
          logger.fine('Navegando para RegisterScreen');
          return const RegisterScreen();
        },
        '/home': (context) {
          logger.fine('Navegando para HomeScreen');
          return const HomeScreen();
        },
        '/create_genealogy': (context) {
          logger.fine('Navegando para CreateGenealogyScreen');
          return const CreateGenealogyScreen();
        },
        '/genealogy': (context) {
          logger.fine('Navegando para GenealogyScreen');
          return const GenealogyScreen();
        },
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        NavigatorObserver(),
      ],
      builder: (context, child) {
        return ErrorHandler(
          logger: logger,
          child: child ?? const SizedBox.shrink(),
        );
      },
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
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      logger.severe('Erro na UI', errorDetails.exception, errorDetails.stack);
      return Material(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Ocorreu um erro inesperado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('Voltar para o início'),
              ),
            ],
          ),
        ),
      );
    };
    return child;
  }
}
