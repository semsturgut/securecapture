import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/shared_domain/services/permission_service.dart';

@LazySingleton(as: PermissionService)
class PermissionServiceImpl implements PermissionService {
  PermissionServiceImpl(this.permission);
  final Permission permission;

  @override
  Future<PermissionStatus> requestPermission() => permission.request();

  @override
  Future<bool> openSettings() => openAppSettings();
}
