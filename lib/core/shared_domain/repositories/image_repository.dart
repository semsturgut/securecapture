import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:securecapture/core/shared_data/models/image.dart';

abstract class ImageRepository {
  Future<void> saveImage(List<int> bytes, List<int> thumbnailBytes, String filename);
  Future<List<ImageModel>> getAllImages();
  Future<List<int>> getImageBytes(String id);
  Future<List<int>> getThumbnailBytes(String id);
  Future<Uint8List> readAsBytes(XFile file);
  Future<List<int>> createThumbnail(Uint8List imageBytes, {int reductionFactor = 8});
}
