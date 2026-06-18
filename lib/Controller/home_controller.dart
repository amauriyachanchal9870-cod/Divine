import 'dart:convert';
import 'package:get/get.dart';
import '../Model/home_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var homeData = Rxn<HomeData>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.homeUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = HomeModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          homeData.value = model.data;
        } else {
          errorMessage.value = 'Failed to load home data.';
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

  List<HomeBanner> get banners => homeData.value?.banners ?? [];
  List<HomeCampaign> get campaigns => homeData.value?.campaigns ?? [];
  List<HomeNgo> get ngos => homeData.value?.ngos ?? [];
  List<HomeDonationHistory> get donationHistory => homeData.value?.donationHistory ?? [];
  HomeUser? get user => homeData.value?.user;
}
