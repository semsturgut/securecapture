import 'package:mockito/annotations.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/managers/permission/permission_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/core/shared_domain/store/app_life_cycle_store.dart';
import 'package:securecapture/features/capture/domain/managers/camera_manager.dart';

@GenerateMocks([
  AuthenticationManager,
  EncryptionManager,
  ImageRepository,
  DatabaseService,
  AppLifeCycleStore,
  PermissionManager,
  CameraManager,
])
void main() {}
