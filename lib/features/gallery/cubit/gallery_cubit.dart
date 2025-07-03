import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/features/gallery/cubit/gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({required this.authenticationManager, required this.imageRepository, required this.encryptionManager})
    : super(const GalleryState()) {
    _isAuthenticatedSubscription = authenticationManager.stream.distinct().listen((isAuthenticated) {
      if (!isAuthenticated) init();
    });
  }

  final AuthenticationManager authenticationManager;
  final ImageRepository imageRepository;
  final EncryptionManager encryptionManager;

  StreamSubscription<bool>? _isAuthenticatedSubscription;

  Future<void> init() async {
    if (state.isLoading) return;
    try {
      emit(state.copyWith(isLoading: true, images: const [], isAuthenticated: false));
      final isAuthenticated = await authenticationManager.authenticate();
      if (!isAuthenticated) throw CommonError("Authentication failed");
      final images = await imageRepository.getAllImages();
      emit(state.copyWith(isAuthenticated: true, isLoading: false, images: images, error: null));
    } on DomainError catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<List<int>> getDecryptedImageBytes(String imageId) async {
    try {
      final bytes = await imageRepository.getImageBytes(imageId);
      return await encryptionManager.decryptImageData(bytes);
    } on DomainError catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
      return [];
    }
  }

  @override
  Future<void> close() {
    authenticationManager.revokeAuthentication();
    _isAuthenticatedSubscription?.cancel();
    return super.close();
  }
}
