import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Widget/app_loader.dart';
import 'package:divine_foundation/Widget/shimmer_widget.dart';

void main() {
  group('Widget Tests - Reusable UI Components', () {
    testWidgets('AppLoader renders correctly with custom size and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoader(
              size: 40.0,
              color: Colors.green,
            ),
          ),
        ),
      );

      // Verify that the AppLoader widget is present in widget tree
      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('ShimmerWidget renders with custom width, height, and border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerWidget(
              width: 120,
              height: 40,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerWidget), findsOneWidget);

      // Advance animation frame
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ShimmerWidget), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(ShimmerWidget), findsOneWidget);
    });
  });
}
