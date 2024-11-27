import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/auth/google_button.dart';
import '../widgets/auth/input_field.dart';
import '../widgets/common/loading_indicator.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                          _tabController.index == 0
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
                      controller: _tabController,
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
                        controller: _tabController,
                        children: const [
                          // Login form
                          LoginForm(),
                          // Register form
                          RegisterForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Componente comum para divisor
class _AuthDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

// Componente comum para botão principal
class _AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _AuthButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login com Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  void _handleForgotPassword(AuthViewModel viewModel) async {
    if (viewModel.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite seu email para recuperar a senha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await viewModel.resetPassword(viewModel.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Email de recuperação enviado. Verifique sua caixa de entrada.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no envio do email de recuperação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLogin(AuthViewModel viewModel) async {
    if (viewModel.emailError != null || viewModel.passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, corrija os erros no formulário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await viewModel.signInWithEmail(
        viewModel.email,
        viewModel.password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          _AuthDivider(),
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
          _AuthButton(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login com Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha no registro: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          _AuthDivider(),
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
          _AuthButton(
            text: 'Registrar',
            onPressed: () => _handleRegister(authViewModel),
            isLoading: authViewModel.isLoading,
          ),
        ],
      ),
    );
  }
}
