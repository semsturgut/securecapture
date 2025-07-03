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
  });
}
