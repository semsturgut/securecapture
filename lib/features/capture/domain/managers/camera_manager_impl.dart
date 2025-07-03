import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/features/capture/domain/managers/camera_manager.dart';

@LazySingleton(as: CameraManager)
class CameraManagerImpl implements CameraManager {
  CameraController? _controller;

  @override
  Future<CameraController> initializeCamera() async {
    try {
      await dispose(); // Clean up existing controller

      final cameras = await availableCameras();
      final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);

      _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);

      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      return _controller!;
    } catch (e) {
      throw CommonError('Failed to initialize camera: ${e.toString()}');
    }
  }

  @override
  Future<XFile> takePicture() async {
    try {
      return await _controller!.takePicture();
    } catch (e) {
      throw CommonError('Failed to take picture: ${e.toString()}');
    }
  }

  @override
  Future<void> dispose() async {
    /// Hot restart will not dispose the camera controller on Android during camera view. Here's the issue:
    /// https://github.com/flutter/flutter/issues/167305#issuecomment-2860423143
    /// This won't be a problem in production.
    await _controller?.dispose();
    _controller = null;
  }
}
