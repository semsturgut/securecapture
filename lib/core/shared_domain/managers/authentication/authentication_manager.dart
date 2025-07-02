abstract class AuthenticationManager {
  /// Authenticate the user using biometric authentication.
  /// Returns true if the authentication is successful.
  /// Returns false if the authentication is cancelled or failed.
  /// Throws [CommonError] if the device does not support biometric authentication.
  Future<bool> authenticate();
}
