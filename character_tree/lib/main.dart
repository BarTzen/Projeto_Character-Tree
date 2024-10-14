import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'view/login_screen.dart';
import 'view/register_screen.dart';
import 'viewmodel/login_viewmodel.dart';
import 'viewmodel/register_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante a inicialização do Flutter
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao inicializar o Firebase: $e');
    }
  }
  runApp(MyAppWithProviders());
}

class MyAppWithProviders extends StatelessWidget {
  const MyAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema escuro
      themeMode: ThemeMode.system, // Alterna de acordo com o sistema
      initialRoute: '/', // Rota inicial
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      debugShowCheckedModeBanner: false, // Remove o banner de debug
    );
  }
}
