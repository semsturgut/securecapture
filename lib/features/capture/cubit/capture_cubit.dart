import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/features/capture/cubit/capture_state.dart';
import 'package:securecapture/core/shared_domain/managers/permission/permission_manager.dart';
import 'package:securecapture/features/capture/domain/managers/camera_manager.dart';

class CaptureCubit extends Cubit<CaptureState> {
  CaptureCubit({
    required this.permissionManager,
    required this.cameraManager,
    required this.imageRepository,
    required this.authenticationManager,
    required this.encryptionManager,
  }) : super(const Loading());
  final PermissionManager permissionManager;
  final CameraManager cameraManager;
  final ImageRepository imageRepository;
  final AuthenticationManager authenticationManager;
  final EncryptionManager encryptionManager;

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
      reset();
    } else {
      emit(const PermissionDenied());
    }
  }

  Future<void> takePicture() async {
    try {
      emit(const Loading());
      final image = await cameraManager.takePicture();
      final imageBytes = await imageRepository.readAsBytes(image);
      final thumbnailBytes = await imageRepository.createThumbnail(imageBytes);

      final encryptedBytes = await encryptionManager.encryptImageData(imageBytes);
      final encryptedThumbnailBytes = await encryptionManager.encryptImageData(thumbnailBytes);

      await imageRepository.saveImage(encryptedBytes, encryptedThumbnailBytes, image.name);
      emit(const Success());
      reset();
    } on DomainError catch (error) {
      emit(Error(error: error));
    }
  }

  void reset() => init(); // Go back to initial state

  @override
  Future<void> close() {
    cameraManager.dispose();
    authenticationManager.revokeAuthentication();
    return super.close();
  }
}
