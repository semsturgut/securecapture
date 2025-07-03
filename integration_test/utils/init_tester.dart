import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart';
import 'package:securecapture/entry_point.dart';

extension InitTester on WidgetTester {
  Future<void> init() async {
    await pumpWidget(await appWrapper(environment: Environment.test));
    await pumpAndSettle();
  }
}
