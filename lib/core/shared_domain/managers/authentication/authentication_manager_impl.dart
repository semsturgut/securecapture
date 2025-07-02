import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_domain/managers/authentication/authentication_manager.dart';
import 'package:securecapture/core/shared_domain/store/app_life_cycle_store.dart';

@LazySingleton(as: AuthenticationManager)
class AuthenticationManagerImpl implements AuthenticationManager {
  AuthenticationManagerImpl(this._localAuthentication, this._appLifeCycleStore) {
    // IDEA: We can also add timeout to clear the cached authentication if the app is
    // in the foreground and inactive for a certain amount of time.
    _lifecycleSubscription = _appLifeCycleStore.stream.distinct().listen((state) {
      switch (state) {
        case AppLifecycleState.paused || AppLifecycleState.detached || AppLifecycleState.hidden:
          _isAuthenticatedController.value = false;
          break;
        default:
      }
    });
  }

  final LocalAuthentication _localAuthentication;
  final AppLifeCycleStore _appLifeCycleStore;

  StreamSubscription<AppLifecycleState>? _lifecycleSubscription;
  final _isAuthenticatedController = BehaviorSubject<bool>.seeded(false);

  @override
  bool get isAuthenticated => _isAuthenticatedController.value;

  @override
  Stream<bool> get stream => _isAuthenticatedController.stream;

  @override
  Future<bool> authenticate() async {
    if (isAuthenticated) return true;

    try {
      final bool isAvailable = await _localAuthentication.isDeviceSupported();
      if (!isAvailable) throw CommonError('Biometric authentication not supported');

      await _localAuthentication.stopAuthentication();
      final bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access your private key',
        options: const AuthenticationOptions(),
      );

      if (isAuthenticated) _isAuthenticatedController.value = true;

      return isAuthenticated;
    } catch (e) {
      throw CommonError('Failed to authenticate: ${e.toString()}');
    }
  }

  @override
  void revokeAuthentication() => _isAuthenticatedController.value = false;

  @override
  void dispose() {
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
  }
}
