import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:securecapture/features/capture/cubit/capture_cubit.dart';
import 'package:securecapture/features/capture/cubit/capture_state.dart';

import '../../../mocks/test_mocks.mocks.dart';

void main() {
  group('CaptureCubit', () {
    late MockPermissionManager permissionManager;
    late MockCameraManager cameraManager;
    late MockImageRepository imageRepository;
    late MockAuthenticationManager authenticationManager;
    late MockEncryptionManager encryptionManager;

    setUp(() {
      permissionManager = MockPermissionManager();
      cameraManager = MockCameraManager();
      imageRepository = MockImageRepository();
      authenticationManager = MockAuthenticationManager();
      encryptionManager = MockEncryptionManager();
    });

    CaptureCubit buildCubit() => CaptureCubit(
      permissionManager: permissionManager,
      cameraManager: cameraManager,
      imageRepository: imageRepository,
      authenticationManager: authenticationManager,
      encryptionManager: encryptionManager,
    );

    group('init', () {
      blocTest<CaptureCubit, CaptureState>(
        'should emit [Loading, PermissionGranted] when init is called with granted permission',
        build: () {
          when(permissionManager.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);
          when(cameraManager.initializeCamera()).thenAnswer(
            (_) async => CameraController(
              CameraDescription(name: 'test', lensDirection: CameraLensDirection.back, sensorOrientation: 0),
              ResolutionPreset.high,
            ),
          );
          return buildCubit();
        },
        act: (cubit) => cubit.init(),
        expect: () => [const Loading(), isA<PermissionGranted>()],
      );

      blocTest<CaptureCubit, CaptureState>(
        'should emit [Loading, PermissionDenied] when init is called with denied permission',
        build: () {
          when(permissionManager.requestPermission()).thenAnswer((_) async => PermissionStatus.denied);
          return buildCubit();
        },
        act: (cubit) => cubit.init(),
        expect: () => [const Loading(), isA<PermissionDenied>()],
      );
    });

    group('openSettings', () {
      blocTest<CaptureCubit, CaptureState>(
        'should emit [Loading, PermissionGranted] after openSettings is called with granted permission',
        build: () {
          when(permissionManager.openSettings()).thenAnswer((_) async => true);
          when(permissionManager.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);
          when(cameraManager.initializeCamera()).thenAnswer(
            (_) async => CameraController(
              CameraDescription(name: 'test', lensDirection: CameraLensDirection.back, sensorOrientation: 0),
              ResolutionPreset.high,
            ),
          );
          return buildCubit();
        },
        act: (cubit) => cubit.openSettings(),
        expect: () => [const Loading(), isA<PermissionGranted>()],
      );

      blocTest<CaptureCubit, CaptureState>(
        'should emit [Loading, PermissionDenied] after openSettings is called with denied permission',
        build: () {
          when(permissionManager.openSettings()).thenAnswer((_) async => false);
          return buildCubit();
        },
        act: (cubit) => cubit.openSettings(),
        expect: () => [const Loading(), isA<PermissionDenied>()],
      );
    });

    group('takePicture', () {
      blocTest<CaptureCubit, CaptureState>(
        'should emit [Loading, Success] after takePicture is called with granted permission',
        build: () {
          when(permissionManager.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);
          when(cameraManager.initializeCamera()).thenAnswer(
            (_) async => CameraController(
              CameraDescription(name: 'test', lensDirection: CameraLensDirection.back, sensorOrientation: 0),
              ResolutionPreset.high,
            ),
          );

          final file = XFile('test.jpg');
          when(cameraManager.takePicture()).thenAnswer((_) async => file);
          when(imageRepository.readAsBytes(file)).thenAnswer((_) async => Uint8List(10));
          when(imageRepository.createThumbnail(Uint8List(10))).thenAnswer((_) async => Uint8List(10));
          when(encryptionManager.encryptImageData(Uint8List(10))).thenAnswer((_) async => Uint8List(10));
          when(imageRepository.saveImage(Uint8List(10), Uint8List(10), file.name)).thenAnswer((_) async => true);
          return buildCubit();
        },
        act: (cubit) async {
          await cubit.init();
          return await cubit.takePicture();
        },
        expect: () => [const Loading(), isA<PermissionGranted>(), isA<Loading>(), isA<Success>(), isA<Loading>(), isA<PermissionGranted>()],
      );
    });
  });
}
