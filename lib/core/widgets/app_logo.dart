import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 80, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'EVOCΛ',
          style: TextStyle(
            fontFamily: 'Outfit', // Using the app's default Google Font
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: -(size * 0.05),
            color: textColor,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
