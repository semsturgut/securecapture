import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback reloadCallback;
  final String? message;
  const ErrorView({required this.reloadCallback, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          const SizedBox(height: 16),
          Text("An error occurred: $message"),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: reloadCallback, child: const Text("RELOAD")),
        ],
      ),
    );
  }
}
