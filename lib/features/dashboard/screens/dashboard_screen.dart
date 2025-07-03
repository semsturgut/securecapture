import 'package:flutter/material.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/widgets/custom_app_bar.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/capture/screens/capture_screen.dart';
import 'package:securecapture/features/gallery/screens/gallery_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void dispose() {
    getIt<DatabaseService>().close();
    getIt<AuthenticationManager>().dispose();
    super.dispose();
  }

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
      appBar: CustomAppBar(title: 'Dashboard'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: const Key('gallery_button'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen())),
              child: const Text('View Gallery'),
            ),
            ElevatedButton(
              key: const Key('capture_button'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CaptureScreen())),
              child: const Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
