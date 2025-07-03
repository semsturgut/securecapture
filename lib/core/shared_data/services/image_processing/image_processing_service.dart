import 'dart:typed_data';

abstract class ImageProcessingService {
  Future<Uint8List> createThumbnail(Uint8List imageBytes, {int size = 100});
}
