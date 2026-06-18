import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../Model/notification_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  var notifications = <NotificationData>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'donor';
      final url = "${ApiUrls.apiBaseUrl}/$role/notifications";

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
          errorMessage.value = 'Failed to load notifications.';
        }
      } else {
        errorMessage.value = 'No response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
