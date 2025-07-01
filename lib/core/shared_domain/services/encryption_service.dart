abstract class EncryptionService {
  /// Generate a new encryption key, and store it in the biometric storage.
  /// This method will skip the generation if the key already exists.
  /// Requires biometric authentication.
  Future<void> generateEncryptionKey();

  /// Get the stored encryption key from the biometric storage.
  /// Requires biometric authentication.
  Future<String?> getStoredKey();

  /// Encrypt the image data.
  Future<List<int>> encryptImageData(List<int> imageBytes);

  /// Decrypt the image data.
  Future<List<int>> decryptImageData(List<int> encryptedBytes);
}
