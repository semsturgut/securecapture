import 'package:flutter/material.dart';
import 'package:securecapture/core/shared_domain/services/encryption_service.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/capture/screens/capture_screen.dart';
// import 'package:securecapture/features/gallery/gallery_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen()));
                await getIt<EncryptionService>().generateEncryptionKey();
                print('key generated');
                final key = await getIt<EncryptionService>().getStoredKey();
                print('key: $key');
              },
              child: const Text('View Gallery'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CaptureScreen()));
              },
              child: const Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
