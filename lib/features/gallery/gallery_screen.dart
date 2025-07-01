import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery'), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(child: const Text('Gallery')),
    );
  }
}
