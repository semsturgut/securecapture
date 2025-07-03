import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securecapture/core/widgets/button.dart';

void main() {
  group('Button Widget', () {
    testWidgets('should render with text only', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(text: 'Test Button', onTap: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      await tester.tap(find.byType(Button));
      expect(tapped, isTrue);
    });

    testWidgets('should render with icon only', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(icon: Icons.camera_alt, onTap: () => tapped = true),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      await tester.tap(find.byType(Button));
      expect(tapped, isTrue);
    });

    testWidgets('should render with both text and icon', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(text: 'Take Picture', icon: Icons.camera_alt, onTap: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Take Picture'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      await tester.tap(find.byType(Button));
      expect(tapped, isTrue);
    });

    testWidgets('should have correct visual properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(text: 'Test', icon: Icons.star, onTap: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(of: find.byType(Button), matching: find.byType(Container)));
      expect(container.padding, const EdgeInsets.all(16));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.color, Colors.black.withValues(alpha: 0.5));
      final clipRRect = tester.widget<ClipRRect>(find.descendant(of: find.byType(Button), matching: find.byType(ClipRRect)));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });
  });
}
