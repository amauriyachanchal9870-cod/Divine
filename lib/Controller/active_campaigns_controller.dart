import 'dart:convert';
import 'package:get/get.dart';
import '../Model/campaign_details_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class ActiveCampaignsController extends GetxController {
  var isLoading = false.obs;
  var activeCampaigns = <CampaignDetailsData>[].obs;
  var errorMessage = ''.obs;
  
  // Filtering state
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveCampaigns();
  }

  Future<void> fetchActiveCampaigns() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.donorCampaignsUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = CampaignsListModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          activeCampaigns.assignAll(model.data!);
        } else {
          errorMessage.value = 'Failed to load active campaigns.';
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

  List<CampaignDetailsData> get filteredCampaigns {
    final cat = selectedCategory.value.toLowerCase().trim();
    final query = searchQuery.value.toLowerCase().trim();

    return activeCampaigns.where((campaign) {
      if (!campaign.isOngoing) return false;

      final matchesSearch = (campaign.title ?? '').toLowerCase().contains(query) ||
                            (campaign.description ?? '').toLowerCase().contains(query);

      if (cat == 'all' || cat.isEmpty) {
        return matchesSearch;
      }

      final campCat = (campaign.category ?? '').toLowerCase();
      bool matchesCategory = campCat == cat;
      if (cat == 'education') {
        matchesCategory = campCat.contains('education') || campCat.contains('book');
      } else if (cat == 'emergency') {
        matchesCategory = campCat.contains('emergency') || campCat.contains('food');
      } else if (cat == 'animal welfare') {
        matchesCategory = campCat.contains('animal') || campCat.contains('cow') || campCat.contains('welfare');
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }
}
