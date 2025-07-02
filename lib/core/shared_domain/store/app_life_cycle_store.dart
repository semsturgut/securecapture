import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

@singleton
class AppLifeCycleStore {
  AppLifeCycleStore() {
    _lifeCycleListener = AppLifecycleListener(onStateChange: _changeState);
  }

  late final AppLifecycleListener _lifeCycleListener;
  final _controller = BehaviorSubject<AppLifecycleState>.seeded(AppLifecycleState.resumed);

  Stream<AppLifecycleState> get stream => _controller.stream;

  AppLifecycleState get value => _controller.value;

  void close() {
    _lifeCycleListener.dispose();
  }

  void _changeState(AppLifecycleState state) {
    _controller.sink.add(state);
  }
}
