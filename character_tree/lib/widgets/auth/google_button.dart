import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GoogleButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/icons/google_logo.png',
            height: 24,
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
