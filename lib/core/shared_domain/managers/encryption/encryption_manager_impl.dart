import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/managers/encryption/encryption_manager.dart';

const String _masterKeyStorageKey = 'secure_capture_master_key';

@LazySingleton(as: EncryptionManager)
class EncryptionManagerImpl implements EncryptionManager {
  EncryptionManagerImpl(this._secureStorage, this._authenticationManager);

  final FlutterSecureStorage _secureStorage;
  final AuthenticationManager _authenticationManager;

  @override
  Future<void> generateEncryptionKey() async {
    try {
      final existingKey = await _secureStorage.read(key: _masterKeyStorageKey);
      if (existingKey != null) return;

      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      final newKey = base64.encode(keyBytes);

      // IDEA: Adjust Android and iOS options to make it more secure
      await _secureStorage.write(key: _masterKeyStorageKey, value: newKey, aOptions: AndroidOptions(), iOptions: IOSOptions());
    } catch (e) {
      throw CommonError('Failed to generate encryption key: ${e.toString()}');
    }
  }

  @override
  Future<List<int>> encryptImageData(List<int> imageBytes) async {
    final keyString = await _getStoredKey();
    if (keyString == null) {
      throw CommonError('No encryption key available');
    }
    // TODO:
    // Performance Roadmap:
    // We can divide the image into chunks and encrypt each chunk separately
    // This will make the encryption faster and more efficient
    // OR, We can use [compute] to encrypt the image in parallel
    // Need to test with large number of images to see which is faster

    // Convert Base64 key to bytes
    final keyBytes = base64.decode(keyString);
    final encryptionKey = Key(keyBytes);

    // Generate random Initialization Vector (16 bytes for AES)
    // Makes the encryption more secure by ensuring that the same image is not encrypted to the same value
    final iv = IV.fromSecureRandom(16);

    // Create AES encrypter
    // AES is the industry standard for symmetric encryption
    final encrypter = Encrypter(AES(encryptionKey));

    final encryptedImage = encrypter.encryptBytes(imageBytes, iv: iv);

    // [IV (16 bytes)] + [Encrypted Image Data]
    final result = <int>[];
    result.addAll(iv.bytes);
    result.addAll(encryptedImage.bytes);

    return result;
  }

  @override
  Future<List<int>> decryptImageData(List<int> encryptedBytes) async {
    try {
      if (encryptedBytes.length < 16) throw CommonError('Invalid encrypted data: too short');

      final keyString = await _getStoredKey();
      if (keyString == null) throw CommonError('No encryption key available');

      final keyBytes = base64.decode(keyString);
      final encryptionKey = Key(keyBytes);
      final iv = IV(Uint8List.fromList(encryptedBytes.take(16).toList()));
      final encrypted = Encrypted(Uint8List.fromList(encryptedBytes.skip(16).toList()));
      final encrypter = Encrypter(AES(encryptionKey));

      return encrypter.decryptBytes(encrypted, iv: iv);
    } catch (e) {
      throw CommonError('Image decryption failed: ${e.toString()}');
    }
  }

  Future<String?> _getStoredKey() async {
    try {
      final bool isAuthenticated = await _authenticationManager.authenticate();

      if (!isAuthenticated) throw CommonError('Failed to authenticate');

      return await _secureStorage.read(key: _masterKeyStorageKey);
    } catch (e) {
      throw CommonError('Failed to retrieve encryption key: ${e.toString()}');
    }
  }
}
