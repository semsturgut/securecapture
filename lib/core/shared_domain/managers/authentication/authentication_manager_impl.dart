import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';

@LazySingleton(as: AuthenticationManager)
class AuthenticationManagerImpl implements AuthenticationManager {
  AuthenticationManagerImpl(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> authenticate() async {
    try {
      final bool isAvailable = await _localAuthentication.isDeviceSupported();
      if (!isAvailable) throw CommonError('Biometric authentication not supported');

      final bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access your key',
        options: const AuthenticationOptions(stickyAuth: true), // Don't dismiss on app switch
      );

      return isAuthenticated;
    } catch (e) {
      throw CommonError('Failed to authenticate: ${e.toString()}');
    }
  }
}
