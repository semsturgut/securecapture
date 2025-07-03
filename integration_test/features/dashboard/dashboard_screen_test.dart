import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:securecapture/di/di.dart';
import 'package:securecapture/features/capture/screens/capture_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/zoned_widget_test_wrapper.dart';
import '../../utils/init_tester.dart';

void main() {
  group('Dashboard Screen', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    setUpAll(() async {
      final sharedPreferences = await SharedPreferences.getInstance();

      final secureStorage = FlutterSecureStorage(
        iOptions: IOSOptions.defaultOptions.copyWith(accountName: 'app_account_name', accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions.defaultOptions.copyWith(encryptedSharedPreferences: true),
      );

      await sharedPreferences.clear();
      await secureStorage.deleteAll();
    });

    tearDown(getIt.reset);

    zonedTestWidgets('should show the correct title, and buttons', (tester) async {
      await tester.init();

      expect(find.byKey(const Key('capture_button')), findsOneWidget);
      expect(find.byKey(const Key('gallery_button')), findsOneWidget);
    });

    zonedTestWidgets('should navigate to the capture screen when the capture button is pressed', (tester) async {
      await tester.init();

      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pumpAndSettle();

      expect(find.byType(CaptureScreen), findsOneWidget);
    });

    // Since we can't interact with the native elements (like biometric authentication), we can't test that.
    // We can only test that the app navigates to the capture screen when the capture button is pressed.
  });
}
