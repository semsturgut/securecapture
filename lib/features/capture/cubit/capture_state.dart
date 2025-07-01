import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:securecapture/core/errors/domain_error.dart';

part 'capture_state.freezed.dart';

/// I used multiple states to handle the permission status and the loading state
/// This is a good practice to handle the state of the app in a clean way.
@freezed
class CaptureState with _$CaptureState {
  const factory CaptureState.loading() = Loading;
  const factory CaptureState.granted({required CameraController cameraController}) = PermissionGranted;
  const factory CaptureState.denied() = PermissionDenied;
  const factory CaptureState.error({required DomainError error}) = Error;
}
