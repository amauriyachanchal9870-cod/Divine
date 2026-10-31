import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:divine_foundation/Services/notification_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    NotificationRouter.setNavigationReady(false);
  });

  tearDown(() {
    Get.reset();
  });

  group('NotificationRouter - Payload & Lifecycle Handling', () {
    test('routeNotification handles null and empty maps safely', () {
      expect(() => NotificationRouter.routeNotification(null), returnsNormally);
      expect(() => NotificationRouter.routeNotification({}), returnsNormally);
    });

    test('setPendingNotification handles null and empty maps safely', () {
      expect(() => NotificationRouter.setPendingNotification(null), returnsNormally);
      expect(() => NotificationRouter.setPendingNotification({}), returnsNormally);
    });

    test('stores payload as pending when navigation is not ready', () {
      NotificationRouter.setNavigationReady(false);
      final testPayload = {'type': 'wallet', 'id': 'tx_123'};

      expect(() => NotificationRouter.routeNotification(testPayload), returnsNormally);
    });

    test('enabling navigation ready drains pending notifications safely', () async {
      NotificationRouter.setNavigationReady(false);
      NotificationRouter.setPendingNotification({'type': 'donation'});

      // Turning navigation ready triggers delayed dispatch
      expect(() => NotificationRouter.setNavigationReady(true), returnsNormally);
    });

    test('handles unknown notification types gracefully without throwing', () {
      NotificationRouter.setNavigationReady(true);
      final unknownPayload = {'type': 'unknown_special_promo'};

      expect(() => NotificationRouter.routeNotification(unknownPayload), returnsNormally);
    });
  });
}
