import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:securecapture/core/errors/domain_error.dart';
import 'package:securecapture/core/shared_data/models/image.dart';

part 'gallery_state.freezed.dart';

@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    @Default([]) List<ImageModel> images,
    DomainError? error,
    Uint8List? imageBytesToShow,
  }) = _GalleryState;
}
