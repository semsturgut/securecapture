import 'dart:async';
import 'dart:typed_data';

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

  static const int _maxCacheSize = 100;
  final Map<String, Uint8List> _thumbnailCache = {};

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

  Future<void> loadThumbnail(String imageId) async {
    if (_thumbnailCache.containsKey(imageId)) {
      emit(state.copyWith(thumbnailCache: Map.from(_thumbnailCache)));
      return;
    }

    try {
      final bytes = await imageRepository.getThumbnailBytes(imageId);
      final decryptedBytes = await encryptionManager.decryptImageData(bytes);
      _manageCacheSize();
      _thumbnailCache[imageId] = Uint8List.fromList(decryptedBytes);
      emit(state.copyWith(thumbnailCache: Map.from(_thumbnailCache)));
    } on DomainError catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Future<void> showImage(String imageId) async {
    try {
      emit(state.copyWith(isImageViewLoading: true));
      final bytes = await imageRepository.getImageBytes(imageId);
      final decryptedBytes = await encryptionManager.decryptImageData(bytes);
      emit(state.copyWith(imageBytesToShow: Uint8List.fromList(decryptedBytes), isImageViewLoading: false));
    } on DomainError catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  // We can also use LRU cache to manage the cache size
  // LRU cache is a cache that removes the least recently used items first
  void _manageCacheSize() {
    if (_thumbnailCache.length >= _maxCacheSize) {
      // Remove oldest entries (first 20 items)
      final keysToRemove = _thumbnailCache.keys.take(20).toList();
      for (final key in keysToRemove) {
        _thumbnailCache.remove(key);
      }
    }
  }

  @override
  Future<void> close() {
    _thumbnailCache.clear();
    authenticationManager.revokeAuthentication();
    _isAuthenticatedSubscription?.cancel();
    return super.close();
  }
}
