import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_data/services/image_processing/image_processing_service.dart';

@LazySingleton(as: ImageProcessingService)
class ImageProcessingServiceImpl implements ImageProcessingService {
  @override
  Future<Uint8List> createThumbnail(Uint8List imageBytes, {int reductionFactor = 8}) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) throw CommonError('Failed to decode image');

      final newWidth = (image.width / reductionFactor).round();
      final newHeight = (image.height / reductionFactor).round();

      final thumbnail = img.copyResize(image, width: newWidth, height: newHeight);
      return Uint8List.fromList(img.encodePng(thumbnail));
    } catch (e) {
      throw CommonError('Failed to create thumbnail: ${e.toString()}');
    }
  }
}
