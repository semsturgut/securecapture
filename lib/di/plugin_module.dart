import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

@module
abstract class PluginModule {
  @lazySingleton
  Permission provideCameraPermission() => Permission.camera;

  @lazySingleton
  FlutterSecureStorage provideFlutterSecureStorage() => FlutterSecureStorage();

  @lazySingleton
  LocalAuthentication provideLocalAuthentication() => LocalAuthentication();
}
