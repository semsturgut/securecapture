import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_data/models/image.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_data/services/image_processing/image_processing_service.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:uuid/uuid.dart';

const _imagesTable = 'encrypted_images';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl(this._databaseService, this._imageProcessingService);

  final DatabaseService _databaseService;
  final ImageProcessingService _imageProcessingService;

  @override
  Future<void> saveImage(List<int> bytes, List<int> thumbnailBytes, String filename) async {
    try {
      final imageId = const Uuid().v4();
      final appDir = await getApplicationDocumentsDirectory();
      final encryptedDir = Directory(join(appDir.path, _imagesTable));
      await encryptedDir.create(recursive: true);

      final encryptedFilePath = join(encryptedDir.path, '$imageId.enc');
      final thumbnailFilePath = join(encryptedDir.path, '${imageId}_thumb.enc');

      await File(encryptedFilePath).writeAsBytes(bytes);
      await File(thumbnailFilePath).writeAsBytes(thumbnailBytes);

      final db = await _databaseService.database;
      await db.insert(_imagesTable, {
        'id': imageId,
        'filename': filename,
        'file_path': encryptedFilePath,
        'thumbnail_path': thumbnailFilePath,
      });
    } catch (e) {
      throw CommonError('Failed to save image: ${e.toString()}');
    }
  }

  @override
  Future<List<ImageModel>> getAllImages() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(_imagesTable);
      return maps
          .map(
            (map) => ImageModel(
              id: map['id'] as String,
              fileName: map['filename'] as String,
              filePath: map['file_path'] as String,
              thumbnailPath: map['thumbnail_path'] as String,
            ),
          )
          .toList();
    } catch (e) {
      throw CommonError('Failed to get images: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> createThumbnail(Uint8List imageBytes, {int size = 100}) async {
    try {
      return await _imageProcessingService.createThumbnail(imageBytes, size: size);
    } catch (e) {
      throw CommonError('Failed to create thumbnail: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> getImageBytes(String id) async {
    try {
      return await _getBytesFromPath(id, 'file_path');
    } catch (e) {
      throw CommonError('Failed to decrypt image: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> getThumbnailBytes(String id) async {
    try {
      return await _getBytesFromPath(id, 'thumbnail_path');
    } catch (e) {
      throw CommonError('Failed to decrypt image: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> readAsBytes(XFile file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw CommonError('Failed to read image: ${e.toString()}');
    }
  }

  Future<List<int>> _getBytesFromPath(String id, String pathColumn) async {
    final db = await _databaseService.database;
    final maps = await db.query(_imagesTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) throw CommonError('Image not found');

    final filePath = maps.first[pathColumn] as String;
    final bytes = await File(filePath).readAsBytes();

    return bytes;
  }
}
