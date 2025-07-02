import 'package:flutter/material.dart';
import 'package:securecapture/features/capture/screens/capture_screen.dart';
import 'package:securecapture/features/gallery/screens/gallery_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Body();
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())),
              child: const Text('View Gallery'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CaptureScreen())),
              child: const Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
