import 'package:securecapture/core/shared_data/models/image.dart';

abstract class ImageRepository {
  Future<void> saveImage(List<int> bytes, String filename);
  Future<List<ImageModel>> getAllImages();
  Future<List<int>> getImageBytes(String id);
}
