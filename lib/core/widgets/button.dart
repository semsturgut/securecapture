import 'dart:ui';

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onTap;
  const Button({this.text, this.icon, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 48)],
                if (text != null) ...[Text(text!, style: const TextStyle(color: Colors.white, fontSize: 24))],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
