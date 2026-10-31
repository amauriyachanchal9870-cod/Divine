import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/campaign_details_model.dart';
import '../Model/campaign_category_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class ActiveCampaignsController extends GetxController {
  var isLoading = false.obs;
  var activeCampaigns = <CampaignDetailsData>[].obs;
  var errorMessage = ''.obs;
  
  // Dynamic categories
  var categoriesList = <CampaignCategoryData>[].obs;
  var isCategoriesLoading = false.obs;

  // Filtering state
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;
  var selectedCampaignTab = 'Active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveCampaigns();
    fetchCampaignCategories();
  }

  Future<void> fetchCampaignCategories({bool forceRefresh = false}) async {
    if (isCategoriesLoading.value) return;
    if (!forceRefresh && categoriesList.isNotEmpty) return;

    try {
      isCategoriesLoading.value = true;
      String url = ApiUrls.donorCampaignCategoriesUrl;
      final response = await Repositories().getApi(
        url: url,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = CampaignCategoryModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          categoriesList.assignAll(model.data!);
        }
      }
    } catch (e) {
      debugPrint("Error fetching campaign categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchActiveCampaigns({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && activeCampaigns.isNotEmpty) return;

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
    final tab = selectedCampaignTab.value;

    return activeCampaigns.where((campaign) {
      if (tab == 'Completed') {
        if (!campaign.isCompleted) return false;
      } else {
        if (!campaign.isOngoing) return false;
      }

      final matchesSearch = (campaign.title ?? '').toLowerCase().contains(query) ||
                            (campaign.description ?? '').toLowerCase().contains(query);

      if (cat == 'all' || cat.isEmpty) {
        return matchesSearch;
      }

      final campCat = (campaign.category ?? '').toLowerCase();
      bool matchesCategory = campCat == cat || campCat.contains(cat) || cat.contains(campCat);
      if (cat == 'education' || cat == 'books') {
        matchesCategory = matchesCategory || campCat.contains('education') || campCat.contains('book');
      } else if (cat == 'emergency' || cat == 'food') {
        matchesCategory = matchesCategory || campCat.contains('emergency') || campCat.contains('food') || campCat.contains('ration');
      } else if (cat == 'animal welfare' || cat == 'animal') {
        matchesCategory = matchesCategory || campCat.contains('animal') || campCat.contains('cow') || campCat.contains('welfare');
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }
}
