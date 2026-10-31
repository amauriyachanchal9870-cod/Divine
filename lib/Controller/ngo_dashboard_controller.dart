import 'dart:convert';
import 'package:get/get.dart';
import '../Model/ngo_dashboard_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class NgoDashboardController extends GetxController {
  var isLoading = false.obs;
  var dashboardData = Rxn<NgoDashboardModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNgoDashboard();
  }

  Future<void> fetchNgoDashboard({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && dashboardData.value != null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.ngoDashboardUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = NgoDashboardModel.fromJson(jsonResponse);
        if (model.status == true) {
          dashboardData.value = model;
        } else {
          errorMessage.value = 'Failed to load NGO dashboard.';
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
