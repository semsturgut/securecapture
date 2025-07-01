import 'dart:convert';
import 'dart:math';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_domain/services/encryption_service.dart';

const String _masterKeyStorageKey = 'secure_capture_master_key';

@LazySingleton(as: EncryptionService)
class EncryptionServiceImpl implements EncryptionService {
  EncryptionServiceImpl(this._biometricStorage);

  final BiometricStorage _biometricStorage;
  BiometricStorageFile? _keyStorage;

  @override
  Future<void> generateEncryptionKey() async {
    try {
      final canAuthenticate = await _biometricStorage.canAuthenticate();
      if (canAuthenticate != CanAuthenticateResponse.success) {
        throw CommonError('Biometric authentication not available: $canAuthenticate');
      }

      final storage = await _getKeyStorage();
      final existingKey = await storage.read();
      if (existingKey != null && existingKey.isNotEmpty) return;

      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      final newKey = base64.encode(keyBytes);
      await storage.write(newKey);
    } catch (e) {
      throw CommonError('Failed to generate encryption key: $e');
    }
  }

  @override
  Future<String?> getStoredKey() async {
    try {
      final storage = await _getKeyStorage();
      return await storage.read();
    } catch (e) {
      throw CommonError('Failed to retrieve encryption key: $e');
    }
  }

  @override
  Future<List<int>> decryptImageData(List<int> encryptedBytes) {
    // TODO: implement decryptImageData
    throw UnimplementedError();
  }

  @override
  Future<List<int>> encryptImageData(List<int> imageBytes) {
    // TODO: implement encryptImageData
    throw UnimplementedError();
  }

  Future<BiometricStorageFile> _getKeyStorage() async {
    _keyStorage ??= await _biometricStorage.getStorage(
      _masterKeyStorageKey,
      options: StorageFileInitOptions(authenticationValidityDurationSeconds: 30),
    );
    return _keyStorage!;
  }
}
