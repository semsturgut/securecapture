import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:securecapture/features/gallery/cubit/gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({required this.authenticationManager, required this.imageRepository}) : super(const GalleryState());
  final AuthenticationManager authenticationManager;
  final ImageRepository imageRepository;

  Future<void> init() async {
    try {
      emit(state.copyWith(isLoading: true));
      final isAuthenticated = await authenticationManager.authenticate();
      if (!isAuthenticated) throw CommonError("Authentication failed");
      final images = await imageRepository.getAllImages();
      emit(state.copyWith(isAuthenticated: true, isLoading: false, images: images));
    } on DomainError catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<List<int>> getDecryptedImageBytes(String imageId) async {
    return await imageRepository.getDecryptedImageBytes(imageId);
  }
}
