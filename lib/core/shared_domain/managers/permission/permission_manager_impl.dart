import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_domain/managers/permission/permission_manager.dart';

@LazySingleton(as: PermissionManager)
class PermissionManagerImpl implements PermissionManager {
  PermissionManagerImpl(this.permission);
  final Permission permission;

  @override
  Future<PermissionStatus> requestPermission() async {
    try {
      return await permission.request();
    } catch (e) {
      throw CommonError(e.toString());
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      throw CommonError(e.toString());
    }
  }
}
