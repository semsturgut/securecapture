import 'package:camera/camera.dart';
import 'package:securecapture/core/shared_data/models/image.dart';

abstract class ImageRepository {
  Future<void> saveImage(XFile image);
  Future<List<ImageModel>> getAllImages();
  Future<List<int>> getDecryptedImageBytes(String id);
}
