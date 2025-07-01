import 'package:biometric_storage/biometric_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

@module
abstract class PluginModule {
  @lazySingleton
  Permission provideCameraPermission() => Permission.camera;

  @lazySingleton
  BiometricStorage provideBiometricStorage() => BiometricStorage();
}