import 'dart:developer';
import 'package:get/get.dart';
import '../Routes/my_routes.dart';

class NotificationRouter {
  static Map<String, dynamic>? _pendingNotificationPayload;
  static bool _isNavigationReady = false;

  static void setNavigationReady(bool ready) {
    _isNavigationReady = ready;
    if (ready && _pendingNotificationPayload != null) {
      final payload = _pendingNotificationPayload!;
      _pendingNotificationPayload = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        routeNotification(payload);
      });
    }
  }

  static void setPendingNotification(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) return;
    log("Setting pending notification payload: $payload");
    _pendingNotificationPayload = payload;
    if (_isNavigationReady) {
      setNavigationReady(true);
    }
  }

  static void routeNotification(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      log("Notification data is empty, skipping routing.");
      return;
    }

    if (!_isNavigationReady) {
      log("Navigation not ready yet. Storing as pending notification.");
      setPendingNotification(data);
      return;
    }

    try {
      log("Routing notification with data: $data");

      String type = (data['type'] ?? data['screen'] ?? data['click_action'] ?? '').toString().toLowerCase().trim();
      String? id = data['id']?.toString() ?? data['campaignId']?.toString() ?? data['ngoId']?.toString();

      switch (type) {
        case 'campaign':
        case 'campaign_details':
        case 'campaigndetails':
          if (id != null && id.isNotEmpty) {
            Get.toNamed(MyRouters.campaignDetailsScreen, arguments: id);
          } else {
            Get.toNamed(MyRouters.ongoingCampaignScreen);
          }
          break;

        case 'ngo':
        case 'ngo_details':
        case 'ngodetails':
          if (id != null && id.isNotEmpty) {
            Get.toNamed(MyRouters.ngoDetailsScreen, arguments: id);
          } else {
            Get.toNamed(MyRouters.ngosScreen);
          }
          break;

        case 'donation':
        case 'donation_history':
        case 'donationhistory':
          Get.toNamed(MyRouters.donationHistoryScreen);
          break;

        case 'fundraiser':
        case 'fundraisers':
          Get.toNamed(MyRouters.fundraisersScreen);
          break;

        case 'wallet':
        case 'transactions':
          Get.toNamed(MyRouters.walletScreen);
          break;

        case 'notification':
        case 'notifications':
          Get.toNamed(MyRouters.notificationScreen);
          break;

        case 'profile':
          Get.toNamed(MyRouters.profileScreen);
          break;

        default:
          log("Unhandled notification type '$type'. Navigating to notification screen or main nav.");
          if (Get.currentRoute != MyRouters.notificationScreen) {
            Get.toNamed(MyRouters.notificationScreen);
          }
          break;
      }
    } catch (e) {
      log("Error during notification routing: $e");
    }
  }
}
