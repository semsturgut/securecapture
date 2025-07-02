import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/features/capture/screens/capture_screen.dart';
import 'package:securecapture/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:securecapture/features/gallery/screens/gallery_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        authenticationManager: context.read<AuthenticationManager>(),
        databaseService: context.read<DatabaseService>(),
      ),
      child: const _Body(),
    );
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
