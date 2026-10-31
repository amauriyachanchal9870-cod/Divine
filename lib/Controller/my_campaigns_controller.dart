import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/campaign_details_model.dart';
import '../Model/campaign_category_model.dart';
import '../Model/my_campaigns_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';

class MyCampaignsController extends GetxController {
  var isLoading = false.obs;
  var myCampaignsData = Rxn<MyCampaignsModel>();
  var errorMessage = ''.obs;

  // Dynamic categories
  var categoriesList = <CampaignCategoryData>[].obs;
  var isCategoriesLoading = false.obs;

  // Track toggling status for activate/deactivate per campaign
  var isTogglingStatus = <String, bool>{}.obs;

  // Search and Category Filters
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;
  var selectedCampaignTab = 'Active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyCampaigns();
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

  Future<void> fetchMyCampaigns({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && myCampaignsData.value != null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.myCampaignsUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = MyCampaignsModel.fromJson(jsonResponse);
        if (model.status == true) {
          myCampaignsData.value = model;
        } else {
          errorMessage.value = 'Failed to load campaigns.';
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
    final campaigns = myCampaignsData.value?.myCampaigns ?? [];
    final cat = selectedCategory.value.toLowerCase().trim();
    final query = searchQuery.value.toLowerCase().trim();
    final tab = selectedCampaignTab.value;

    return campaigns.where((campaign) {
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

  Future<bool> toggleCampaignActiveStatus(
    String campaignId,
    bool isCurrentlyActive,
    BuildContext? context, {
    String? deactivationReason,
  }) async {
    if (campaignId.isEmpty) return false;
    if (isTogglingStatus[campaignId] == true) return false;

    try {
      isTogglingStatus[campaignId] = true;
      // When campaign is currently active, deactivate it -> /deactivate
      // When campaign is currently inactive, activate it -> /activate
      final bool shouldActivate = !isCurrentlyActive;
      final url = shouldActivate
          ? ApiUrls.activateCampaignUrl(campaignId)
          : ApiUrls.deactivateCampaignUrl(campaignId);

      Map<String, dynamic>? body;
      if (!shouldActivate) {
        body = {
          "deactivationReason": deactivationReason ?? "",
        };
      }

      final response = await Repositories().putApi(
        context: context,
        url: url,
        mapData: body,
        showResponse: true,
      );

      if (response != null && response is String && response.trim().startsWith('{')) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        final bool isSuccess = jsonResponse['status'] != false && jsonResponse['status'] != 'error';
        final message = jsonResponse['message'] ??
            (shouldActivate ? 'Campaign activated successfully' : 'Campaign deactivated successfully');

        showSnackBar(message, isSuccess);

        if (isSuccess) {
          final dynamic activeVal = jsonResponse['isActive'] ??
              jsonResponse['active'] ??
              jsonResponse['activate'] ??
              jsonResponse['is_active'];

          final campaigns = myCampaignsData.value?.myCampaigns;
          if (campaigns != null) {
            final index = campaigns.indexWhere((c) => c.sId == campaignId);
            if (index != -1) {
              if (activeVal != null && activeVal is bool) {
                campaigns[index].isActive = activeVal;
              } else {
                campaigns[index].isActive = shouldActivate;
              }
              myCampaignsData.refresh();
            }
          }
        }
        return isSuccess;
      } else {
        showSnackBar("Failed to update campaign status", false);
      }
    } catch (e) {
      debugPrint("Error toggling campaign status: $e");
      showSnackBar("Error updating status: $e", false);
    } finally {
      isTogglingStatus[campaignId] = false;
    }
    return false;
  }
}
