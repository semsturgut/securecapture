import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  /// Request permission to use the camera
  /// Returns a [PermissionStatus]
  Future<PermissionStatus> requestPermission();

  /// Open the settings page
  /// Returns true if the settings page is opened successfully
  Future<bool> openSettings();
}
