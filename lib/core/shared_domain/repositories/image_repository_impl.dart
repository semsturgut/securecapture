import 'dart:io';

import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_data/models/image.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';
import 'package:securecapture/core/shared_domain/repositories/image_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl(this._encryptionManager, this._databaseService);

  final EncryptionManager _encryptionManager;
  final DatabaseService _databaseService;

  @override
  Future<void> saveImage(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final encryptedBytes = await _encryptionManager.encryptImageData(imageBytes);

      final imageId = const Uuid().v4();
      final appDir = await getApplicationDocumentsDirectory();
      final encryptedDir = Directory(join(appDir.path, 'encrypted_images'));
      await encryptedDir.create(recursive: true);
      final encryptedFilePath = join(encryptedDir.path, '$imageId.enc');

      await File(encryptedFilePath).writeAsBytes(encryptedBytes);

      final db = await _databaseService.database;
      await db.insert('encrypted_images', {'id': imageId, 'filename': image.name, 'file_path': encryptedFilePath});
    } catch (e) {
      throw CommonError('Failed to save image: ${e.toString()}');
    }
  }

  @override
  Future<List<ImageModel>> getAllImages() async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('encrypted_images');
      return maps
          .map((map) => ImageModel(id: map['id'] as String, fileName: map['filename'] as String, filePath: map['file_path'] as String))
          .toList();
    } catch (e) {
      throw CommonError('Failed to get images: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> getDecryptedImageBytes(String id) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query('encrypted_images', where: 'id = ?', whereArgs: [id], limit: 1);
      if (maps.isEmpty) throw CommonError('Image not found');

      final filePath = maps.first['file_path'] as String;
      final encryptedBytes = await File(filePath).readAsBytes();

      return await _encryptionManager.decryptImageData(encryptedBytes);
    } catch (e) {
      throw CommonError('Failed to decrypt image: ${e.toString()}');
    }
  }
}
