import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/dashboard/dashboard_screen.dart';

void run({required String environment}) {
  runZonedGuarded<Future<void>>(() async => runApp(await appWrapper(environment: environment)), (error, stack) {
    // Error reporting tools like Firebase Crashlytics or Sentry can be used here
  });
}

Future<Widget> appWrapper({required String environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await configureDependencies(environment);
  getIt.registerSingleton(Environment(environment));
  return _App();
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => const DashboardScreen()));
  }
}
