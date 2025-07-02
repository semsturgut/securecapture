import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/features/capture/cubit/capture_state.dart';
import 'package:securecapture/core/shared_domain/managers/permission/permission_manager.dart';
import 'package:securecapture/features/capture/domain/managers/camera_manager.dart';

class CaptureCubit extends Cubit<CaptureState> {
  CaptureCubit({
    required this.permissionManager,
    required this.cameraManager,
    required this.encryptionManager,
    required this.imageRepository,
  }) : super(const Loading());
  final PermissionManager permissionManager;
  final CameraManager cameraManager;
  final EncryptionManager encryptionManager;
  final ImageRepository imageRepository;

  Future<void> init() async {
    try {
      emit(const Loading());
      final permissionStatus = await permissionManager.requestPermission();
      if (permissionStatus.isGranted) {
        final cameraController = await cameraManager.initializeCamera();
        emit(PermissionGranted(cameraController: cameraController));
      } else if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        emit(const PermissionDenied());
      }
    } on DomainError catch (error) {
      emit(Error(error: error));
    }
  }

  Future<void> openSettings() async {
    emit(const Loading());
    final result = await permissionManager.openSettings();
    if (result) {
      await init();
    } else {
      emit(const PermissionDenied());
    }
  }

  Future<void> takePicture() async {
    try {
      final image = await cameraManager.takePicture();
      await imageRepository.saveImage(image);
      emit(const Success());
      init();
    } on DomainError catch (error) {
      emit(Error(error: error));
    }
  }

  @override
  Future<void> close() {
    cameraManager.dispose();
    return super.close();
  }
}
