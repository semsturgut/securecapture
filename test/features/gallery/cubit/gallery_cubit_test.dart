import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_data/models/image.dart';
import 'package:securecapture/features/gallery/cubit/gallery_cubit.dart';
import 'package:securecapture/features/gallery/cubit/gallery_state.dart';

import '../../../mocks/test_mocks.mocks.dart';

const _fakeImage = ImageModel(id: '1', fileName: 'test.jpg', filePath: 'test.jpg', thumbnailPath: 'test.jpg');

void main() {
  group('GalleryCubit', () {
    late MockImageRepository imageRepository;
    late MockAuthenticationManager authenticationManager;
    late MockEncryptionManager encryptionManager;

    late BehaviorSubject<bool> authenticationStreamController;

    setUpAll(() {
      authenticationStreamController = BehaviorSubject<bool>.seeded(false);
    });

    tearDownAll(() {
      authenticationStreamController.close();
    });

    setUp(() {
      imageRepository = MockImageRepository();
      authenticationManager = MockAuthenticationManager();
      encryptionManager = MockEncryptionManager();

      when(authenticationManager.stream).thenAnswer((_) => authenticationStreamController.stream);
    });

    GalleryCubit buildCubit() =>
        GalleryCubit(imageRepository: imageRepository, authenticationManager: authenticationManager, encryptionManager: encryptionManager);

    group('init', () {
      test('should emit GalleryState with [_fakeImage] when gallery is loaded', () async {
        when(authenticationManager.authenticate()).thenAnswer((_) async => true);
        when(imageRepository.getAllImages()).thenAnswer((_) async => [_fakeImage]);
        final cubit = buildCubit();
        await cubit.init();
        verify(authenticationManager.authenticate()).called(1);
        verify(imageRepository.getAllImages()).called(1);
        expect(cubit.state, const GalleryState(isLoading: false, images: [_fakeImage], isAuthenticated: true));
      });

      test('should emit GalleryState with [CommonError] when authentication fails', () async {
        when(authenticationManager.authenticate()).thenAnswer((_) async => false);
        final cubit = buildCubit();
        await cubit.init();
        verify(authenticationManager.authenticate()).called(1);
        verifyNever(imageRepository.getAllImages());
        expect(cubit.state.isLoading, false);
        expect(cubit.state.images, const []);
        expect(cubit.state.isAuthenticated, false);
        expect(cubit.state.error, isA<CommonError>());
      });

      test('should emit GalleryState with [CommonError] when image repository throws an error', () async {
        when(authenticationManager.authenticate()).thenAnswer((_) async => true);
        when(imageRepository.getAllImages()).thenThrow(CommonError('Error'));
        final cubit = buildCubit();
        await cubit.init();
        verify(authenticationManager.authenticate()).called(1);
        verify(imageRepository.getAllImages()).called(1);
        expect(cubit.state.isLoading, false);
      });
    });

    group('loadThumbnail', () {
      test('should add thumbnail to cache and emit GalleryState with thumbnailCache', () async {
        authenticationStreamController.add(true); // Authentication required
        when(imageRepository.getThumbnailBytes('1')).thenAnswer((_) async => Uint8List(100));
        when(encryptionManager.decryptImageData(any)).thenAnswer((_) async => Uint8List(100));
        final cubit = buildCubit();
        await cubit.loadThumbnail('1');
        verify(imageRepository.getThumbnailBytes('1')).called(1);
        verify(encryptionManager.decryptImageData(any)).called(1);
        expect(cubit.state.thumbnailCache, {'1': Uint8List(100)});
      });

      test('should not add thumbnail to cache if it already exists', () async {
        authenticationStreamController.add(true); // Authentication required
        when(imageRepository.getThumbnailBytes('1')).thenAnswer((_) async => Uint8List(100));
        when(encryptionManager.decryptImageData(any)).thenAnswer((_) async => Uint8List(100));
        final cubit = buildCubit();
        await cubit.loadThumbnail('1');
        verify(imageRepository.getThumbnailBytes('1')).called(1);
        verify(encryptionManager.decryptImageData(any)).called(1);
        expect(cubit.state.thumbnailCache, {'1': Uint8List(100)});

        when(imageRepository.getThumbnailBytes('1')).thenAnswer((_) async => Uint8List(100));
        when(encryptionManager.decryptImageData(any)).thenAnswer((_) async => Uint8List(100));
        await cubit.loadThumbnail('1');
        verifyNever(imageRepository.getThumbnailBytes('1'));
        verifyNever(encryptionManager.decryptImageData(any));
        expect(cubit.state.thumbnailCache, {'1': Uint8List(100)});
      });

      test('should emit GalleryState with [CommonError] when image repository throws an error', () async {
        authenticationStreamController.add(true); // Authentication required
        when(imageRepository.getThumbnailBytes('1')).thenThrow(CommonError('Error'));
        final cubit = buildCubit();
        await cubit.loadThumbnail('1');
        verify(imageRepository.getThumbnailBytes('1')).called(1);
        verifyNever(encryptionManager.decryptImageData(any));
        expect(cubit.state.error, isA<CommonError>());
      });
    });

    group('showImage', () {
      test('should emit GalleryState with imageBytesToShow', () async {
        authenticationStreamController.add(true); // Authentication required
        when(imageRepository.getImageBytes('1')).thenAnswer((_) async => Uint8List(100));
        when(encryptionManager.decryptImageData(any)).thenAnswer((_) async => Uint8List(100));
        final cubit = buildCubit();
        await cubit.showImage('1');
        verify(imageRepository.getImageBytes('1')).called(1);
        verify(encryptionManager.decryptImageData(any)).called(1);
        expect(cubit.state.imageBytesToShow, Uint8List(100));
      });

      test('should emit GalleryState with [CommonError] when image repository throws an error', () async {
        authenticationStreamController.add(true); // Authentication required
        when(imageRepository.getImageBytes('1')).thenThrow(CommonError('Error'));
        final cubit = buildCubit();
        await cubit.showImage('1');
        verify(imageRepository.getImageBytes('1')).called(1);
        verifyNever(encryptionManager.decryptImageData(any));
        expect(cubit.state.error, isA<CommonError>());
      });
    });

    group('authenticationManager stream', () {
      test('should call reauthenticate when app authentication is revoked and authentication is successful', () async {
        fakeAsync((async) async {
          authenticationStreamController.add(true); // Authentication required
          when(authenticationManager.authenticate()).thenAnswer((_) async => true);
          when(imageRepository.getAllImages()).thenAnswer((_) async => [_fakeImage]);
          final cubit = buildCubit();
          await cubit.init();
          expect(cubit.state.isAuthenticated, true);
          authenticationStreamController.add(false);
          async.flushMicrotasks();
          verify(authenticationManager.authenticate()).called(1);
          verify(imageRepository.getAllImages()).called(1);
          expect(cubit.state.isAuthenticated, true);
          expect(cubit.state.images, [_fakeImage]);
        });
      });

      test('should call reauthenticate when app authentication is revoked and authentication is not successful', () async {
        // fakeAsync is used to wait for the authenticationStreamController to emit a value
        fakeAsync((async) async {
          authenticationStreamController.add(true); // Authentication required
          when(authenticationManager.authenticate()).thenAnswer((_) async => true);
          when(imageRepository.getAllImages()).thenAnswer((_) async => [_fakeImage]);
          final cubit = buildCubit();
          await cubit.init();
          expect(cubit.state.isAuthenticated, true);
          authenticationStreamController.add(false);
          async.flushMicrotasks();
          when(authenticationManager.authenticate()).thenAnswer((_) async => false);
          verify(authenticationManager.authenticate()).called(1);
          verify(imageRepository.getAllImages()).called(1);
          expect(cubit.state.error, isA<CommonError>());
        });
      });
    });
  });
}
