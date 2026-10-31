import 'dart:convert';
import 'package:get/get.dart';
import '../Model/notification_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/app_string.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationData>[].obs;
  var errorMessage = ''.obs;


  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && notifications.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = ApiUrls.notificationsUrl;

      final response = await Repositories().getApi(
        url: url,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = NotificationModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          notifications.assignAll(model.data!);
        } else {
          errorMessage.value = AppString.failedToLoadNotifications.tr;
        }
      } else {
        errorMessage.value = AppString.noResponseFromServer.tr;
      }
    } catch (e) {
      errorMessage.value = AppString.errorPrefix.trParams({'error': e.toString()});
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationsAsRead() async {
    try {
      final url = ApiUrls.readNotificationsUrl;
      final response = await Repositories().postApi(
        url: url,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          for (var notification in notifications) {
            notification.isRead = true;
          }
          notifications.refresh();
        }
      }
    } catch (e) {
      // Quietly log and ignore to prevent disrupting user experience
      print("Error marking notifications as read: $e");
    }
  }
}
