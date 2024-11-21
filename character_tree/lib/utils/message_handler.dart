import 'package:flutter/material.dart';

class MessageHandler {
  static void showError(BuildContext context, String message) {
    _showMessage(context, message, Colors.red);
  }

  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, message, Colors.green);
  }

  static void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
