import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;

  const LoadingIndicator({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
