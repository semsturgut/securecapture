import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/shared_domain/managers/permission/permission_manager.dart';

@LazySingleton(as: PermissionManager)
class PermissionManagerImpl implements PermissionManager {
  PermissionManagerImpl(this.permission);
  final Permission permission;

  @override
  Future<PermissionStatus> requestPermission() => permission.request();

  @override
  Future<bool> openSettings() => openAppSettings();
}
