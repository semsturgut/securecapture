import 'package:camera/camera.dart';

abstract class CameraManager {
  /// Initialize the camera
  /// Returns a [CameraController] if the camera is initialized successfully
  /// Throws a [DomainError] if the camera is not initialized successfully
  /// Always dispose the camera controller when the camera is not needed
  Future<CameraController> initializeCamera();

  /// Take a picture
  /// Returns a [XFile] if the picture is taken successfully
  /// Throws a [DomainError] if the picture is not taken successfully
  Future<XFile> takePicture();

  /// Dispose the camera
  Future<void> dispose();
}
