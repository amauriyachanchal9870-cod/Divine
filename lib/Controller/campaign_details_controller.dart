import 'dart:convert';
import 'package:get/get.dart';
import '../Model/campaign_details_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class CampaignDetailsController extends GetxController {
  final String campaignId;
  var isLoading = false.obs;
  var campaignDetails = Rxn<CampaignDetailsData>();
  var errorMessage = ''.obs;

  CampaignDetailsController({required this.campaignId});

  @override
  void onInit() {
    super.onInit();
    fetchCampaignDetails();
  }

  Future<void> fetchCampaignDetails() async {
    if (campaignId.isEmpty) {
      errorMessage.value = 'Campaign ID is missing.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.getCampaignDetailsUrl(campaignId),
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = CampaignDetailsModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          campaignDetails.value = model.data;
        } else {
          errorMessage.value = 'Failed to load campaign details.';
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
