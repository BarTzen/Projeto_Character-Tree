import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/message_handler.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth/google_button.dart';
import '../widgets/auth/input_field.dart';
import '../widgets/common/loading_indicator.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        final tabController = DefaultTabController.of(context);
        return Scaffold(
          backgroundColor: Colors.blueGrey[100],
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo e mensagem inicial
                      Column(
                        children: [
                          Image.asset(
                            'lib/assets/images/tree_logo.png',
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tabController.index == 0
                                ? 'Entre para continuar sua jornada\nnas genealogias literárias'
                                : 'Crie sua conta para começar a explorar as\ngenealogia literárias',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Tabs Login/Registro
                      TabBar(
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Registro'),
                        ],
                        labelColor: Colors.blue[900],
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: Colors.blue[900],
                      ),
                      const SizedBox(height: 20),

                      // Conteúdo das tabs
                      SizedBox(
                        height: 400, // Altura fixa para o conteúdo
                        child: TabBarView(
                          children: [
                            // Login form com chave única
                            SingleChildScrollView(
                              child: Form(
                                key: GlobalKey<FormState>(
                                    debugLabel: 'loginForm'),
                                child: const LoginForm(),
                              ),
                            ),
                            // Register form com chave única
                            SingleChildScrollView(
                              child: Form(
                                key: GlobalKey<FormState>(
                                    debugLabel: 'registerForm'),
                                child: const RegisterForm(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  void _handleGoogleSignIn(AuthViewModel viewModel) async {
    try {
      await viewModel.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      MessageHandler.showError(context, e.toString());
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.blue[900])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('ou', style: TextStyle(color: Colors.blue[900])),
          ),
          Expanded(child: Divider(color: Colors.blue[900])),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(AuthViewModel viewModel) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _handleForgotPassword(viewModel),
        child: const Text('Esqueceu a senha?'),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[900],
        ),
        child: isLoading
            ? const LoadingIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _handleForgotPassword(AuthViewModel viewModel) async {
    if (viewModel.email.isEmpty) {
      MessageHandler.showError(
          context, 'Digite seu email para recuperar a senha');
      return;
    }
    try {
      await viewModel.resetPassword(viewModel.email);
      if (!mounted) return;
      MessageHandler.showSuccess(
        context,
        'Email de recuperação enviado. Verifique sua caixa de entrada.',
      );
    } catch (e) {
      if (!mounted) return;
      MessageHandler.showError(context, e.toString());
    }
  }

  void _handleLogin(AuthViewModel viewModel) async {
    if (viewModel.emailError != null || viewModel.passwordError != null) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await viewModel.signInWithEmail(
          viewModel.email,
          viewModel.password,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (!mounted) return;
        MessageHandler.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          GoogleButton(
            onPressed: () => _handleGoogleSignIn(authViewModel),
            text: 'Continuar com Google',
          ),
          _buildDivider(),
          AuthInputField(
            icon: Icons.email,
            hint: 'Email',
            onChanged: authViewModel.setEmail,
            errorText: authViewModel.emailError,
          ),
          const SizedBox(height: 16),
          AuthPasswordField(
            onChanged: authViewModel.setPassword,
            errorText: authViewModel.passwordError,
            isVisible: authViewModel.isPasswordVisible,
            onToggleVisibility: authViewModel.togglePasswordVisibility,
          ),
          const SizedBox(height: 8),
          _buildForgotPassword(authViewModel),
          const SizedBox(height: 16),
          _buildMainButton(
            text: 'Entrar',
            onPressed: () => _handleLogin(authViewModel),
            isLoading: authViewModel.isLoading,
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  void _handleGoogleSignIn(AuthViewModel viewModel) async {
    try {
      await viewModel.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      MessageHandler.showError(context, e.toString());
    }
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.blue[900])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('ou', style: TextStyle(color: Colors.blue[900])),
          ),
          Expanded(child: Divider(color: Colors.blue[900])),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[900],
        ),
        child: isLoading
            ? const LoadingIndicator(color: Colors.white)
            : Text(text,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  void _handleRegister(AuthViewModel viewModel) async {
    if (viewModel.emailError != null ||
        viewModel.passwordError != null ||
        viewModel.nameError != null) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await viewModel.registerWithEmail(
          viewModel.email,
          viewModel.password,
          viewModel.name,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (!mounted) return;
        MessageHandler.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          GoogleButton(
            onPressed: () => _handleGoogleSignIn(authViewModel),
            text: 'Continuar com Google',
          ),
          _buildDivider(),
          AuthInputField(
            icon: Icons.person,
            hint: 'Nome',
            onChanged: authViewModel.setName,
            errorText: authViewModel.nameError,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            icon: Icons.email,
            hint: 'Email',
            onChanged: authViewModel.setEmail,
            errorText: authViewModel.emailError,
          ),
          const SizedBox(height: 16),
          AuthPasswordField(
            onChanged: authViewModel.setPassword,
            errorText: authViewModel.passwordError,
            isVisible: authViewModel.isPasswordVisible,
            onToggleVisibility: authViewModel.togglePasswordVisibility,
          ),
          const SizedBox(height: 24),
          _buildMainButton(
            text: 'Registrar',
            onPressed: () => _handleRegister(authViewModel),
            isLoading: authViewModel.isLoading,
          ),
        ],
      ),
    );
  }
}
