// register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth/register_viewmodel.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registerViewModel = context.watch<RegisterViewModel>();

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
                    'Crie sua conta para começar a explorar as\n'
                    'genealogias literárias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // TÍTULO "CRIAR UMA CONTA"
                  Text(
                    'Criar uma Conta',
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
                      onPressed: () =>
                          registerViewModel.signUpWithGoogle(context),
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
                      Expanded(
                        child: Divider(color: Colors.blue[900]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.blue[900]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE USUÁRIO
                  TextFormField(
                    onChanged: registerViewModel.setUsername,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.black54),
                      hintText: 'Usuário',
                      hintStyle: TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      errorText: registerViewModel.usernameError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE EMAIL
                  TextFormField(
                    onChanged: registerViewModel.setEmail,
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
                      errorText: registerViewModel.emailError,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE SENHA COM ÍCONE DE VISIBILIDADE
                  ValueListenableBuilder<bool>(
                    valueListenable: registerViewModel.isPasswordVisible,
                    builder: (context, isVisible, _) {
                      return TextFormField(
                        onChanged: registerViewModel.setPassword,
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
                            onPressed:
                                registerViewModel.togglePasswordVisibility,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          errorText: registerViewModel.passwordError,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO DE CONFIRMAR SENHA
                  ValueListenableBuilder<bool>(
                    valueListenable: registerViewModel.isPasswordVisible,
                    builder: (context, isVisible, _) {
                      return TextFormField(
                        onChanged: registerViewModel.setConfirmPassword,
                        obscureText: !isVisible,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.black54),
                          hintText: 'Confirmar Senha',
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
                            onPressed:
                                registerViewModel.togglePasswordVisibility,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          errorText: registerViewModel.confirmPasswordError,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // BOTÃO "CADASTRAR"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerViewModel.isLoading
                          ? null
                          : () => registerViewModel.register(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: registerViewModel.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TEXTO "JÁ TEM UMA CONTA? CONECTE-SE"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem uma conta?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/'),
                        child: Text(
                          'Conecte-se',
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
