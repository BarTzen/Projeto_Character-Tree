// login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO DO APP
                  Image.asset(
                    'lib/assets/images/tree_logo.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),

                  // MENSAGEM ABAIXO DO LOGO
                  Text(
                    'Entre para continuar sua jornada\nnas genealogias literárias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // TÍTULO "CONECTE-SE"
                  Text(
                    'Conecte-se',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BOTÃO "CONTINUAR COM GOOGLE"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => loginViewModel.signInWithGoogle(context),
                      icon: Image.asset(
                        'lib/assets/icons/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        'Continuar com Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LINHA DIVISÓRIA COM "OU"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.blue[900])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('ou',
                            style: TextStyle(color: Colors.blue[900])),
                      ),
                      Expanded(child: Divider(color: Colors.blue[900])),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE EMAIL
                  TextFormField(
                    onChanged: loginViewModel.setEmail,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.black54),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      errorText: loginViewModel.emailError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE SENHA
                  ValueListenableBuilder<bool>(
                    valueListenable: loginViewModel.isPasswordVisible,
                    builder: (context, isVisible, _) {
                      return TextFormField(
                        onChanged: loginViewModel.setPassword,
                        obscureText: !isVisible,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.black54),
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: loginViewModel.togglePasswordVisibility,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          errorText: loginViewModel.passwordError,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // "ESQUECEU SUA SENHA?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => loginViewModel.resetPassword(context),
                      child: Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO "CONTINUAR"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginViewModel.isLoading
                          ? null
                          : () => loginViewModel.login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loginViewModel.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TEXTO "NÃO TEM UMA CONTA? CADASTRE-SE"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
