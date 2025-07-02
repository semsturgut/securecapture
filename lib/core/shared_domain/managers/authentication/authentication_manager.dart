abstract class AuthenticationManager {
  /// Whether the authentication is cached.
  bool get isAuthenticated;

  /// Stream of the authentication status.
  Stream<bool> get stream;

  /// Authenticate the user using biometric authentication.
  /// Returns true if the authentication is successful.
  /// Returns false if the authentication is cancelled or failed.
  /// Throws [CommonError] if the device does not support biometric authentication.
  Future<bool> authenticate();

  /// Manually revoke the cached authentication.
  void revokeAuthentication();

  /// Dispose the authentication manager.
  void dispose();
}
