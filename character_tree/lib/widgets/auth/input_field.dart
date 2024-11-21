import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const AuthInputField({
    super.key,
    required this.icon,
    required this.hint,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) {
        onChanged(value);
        Form.of(context).validate(); // Validação em tempo real
      },
      validator: (value) => errorText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const AuthPasswordField({
    super.key,
    required this.onChanged,
    required this.errorText,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggleVisibility,
        ),
        hintText: 'Senha',
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
