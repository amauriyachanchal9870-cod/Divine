import 'dart:convert';
import 'package:get/get.dart';
import '../Model/home_model.dart';
import '../Model/recent_search_model.dart';
import '../Controller/home_controller.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class CampaignSearchController extends GetxController {
  var isLoadingRecent = false.obs;
  var recentSearches = <String>[].obs;
  var searchQuery = ''.obs;
  
  late final HomeController _homeController;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<HomeController>()) {
      _homeController = Get.find<HomeController>();
    } else {
      _homeController = Get.put(HomeController());
    }
    fetchRecentSearches();
  }

  Future<void> fetchRecentSearches() async {
    try {
      isLoadingRecent.value = true;
      final response = await Repositories().getApi(
        url: ApiUrls.recentSearchesUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = RecentSearchModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          recentSearches.assignAll(model.data!);
        }
      }
    } catch (e) {
      // Ignored
    } finally {
      isLoadingRecent.value = false;
    }
  }

  void addRecentSearchLocal(String query) {
    if (query.trim().isEmpty) return;
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }
  }

  void removeRecentSearchLocal(String query) {
    recentSearches.remove(query);
  }

  Future<void> saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    addRecentSearchLocal(trimmed);
    try {
      await Repositories().postApi(
        url: ApiUrls.recentSearchesUrl,
        mapData: {
          "search": trimmed,
          "keyword": trimmed,
        },
        showResponse: true,
      );
    } catch (e) {
      // Silently fall back to local list update
    }
  }

  Future<void> removeRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    removeRecentSearchLocal(trimmed);
    try {
      await Repositories().deleteApi(
        url: ApiUrls.recentSearchesUrl,
        mapData: {
          "search": trimmed,
          "keyword": trimmed,
        },
        showResponse: true,
      );
    } catch (e) {
      // Silently fall back to local list update
    }
  }

  List<HomeCampaign> get filteredCampaigns {
    final query = searchQuery.value.trim().toLowerCase();
    final allCampaigns = _homeController.campaigns;
    if (query.isEmpty) {
      return allCampaigns;
    }
    return allCampaigns.where((c) {
      final title = c.title?.toLowerCase() ?? '';
      final description = c.description?.toLowerCase() ?? '';
      final category = c.category?.toLowerCase() ?? '';
      final user = c.user?.toLowerCase() ?? '';
      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query) ||
          user.contains(query);
    }).toList();
  }
}
