import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@isTest
void zonedTestWidgets(
  String description,
  WidgetTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
}) {
  testWidgets(
    description,
    (tester) async {
      final originalOnError = FlutterError.onError;
      await runZonedGuarded(
        () async {
          await callback(tester);
        },
        (error, stackTrace) {
          // need to return onError back to original or else the test framework will complain
          FlutterError.onError = originalOnError;
        },
      );
    },
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
  );
}
