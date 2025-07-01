import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/features/capture/cubit/capture_state.dart';
import 'package:securecapture/core/shared_domain/services/permission_service.dart';
import 'package:securecapture/features/capture/domain/services/camera_service.dart';

class CaptureCubit extends Cubit<CaptureState> {
  CaptureCubit({required this.permissionService, required this.cameraService}) : super(const Loading());
  final PermissionService permissionService;
  final CameraService cameraService;

  Future<void> init() async {
    try {
      emit(const Loading());
      final permissionStatus = await permissionService.requestPermission();
      if (permissionStatus.isGranted) {
        final cameraController = await cameraService.initializeCamera();
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
    final result = await permissionService.openSettings();
    if (result) {
      await init();
    } else {
      emit(const PermissionDenied());
    }
  }

  Future<void> takePicture() async {
    try {
      // final image = await cameraService.takePicture();
    } on DomainError catch (error) {
      emit(Error(error: error));
    }
  }

  @override
  Future<void> close() {
    cameraService.dispose();
    return super.close();
  }
}
