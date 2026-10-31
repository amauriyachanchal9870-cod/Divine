import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Model/screen_banner_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class BannerController extends GetxController {
  var screenBanners = <String, ScreenBannerModel>{}.obs;
  var loadingScreens = <String, bool>{}.obs;

  bool isLoading(String screenName) => loadingScreens[screenName] ?? false;

  ScreenBannerModel? getBannerModel(String screenName) => screenBanners[screenName];

  List<BannerItem> getTopBanners(String screenName) {
    return screenBanners[screenName]?.top ?? [];
  }

  List<BannerItem> getBottomBanners(String screenName) {
    return screenBanners[screenName]?.bottom ?? [];
  }

  Future<ScreenBannerModel?> fetchBanners(String screenName, {bool forceRefresh = false}) async {
    if (screenName.isEmpty) return null;
    if (!forceRefresh && screenBanners.containsKey(screenName) && screenBanners[screenName] != null) {
      return screenBanners[screenName];
    }
    if (isLoading(screenName)) {
      return screenBanners[screenName];
    }

    try {
      loadingScreens[screenName] = true;
      loadingScreens.refresh();

      final response = await Repositories().getApi(
        url: ApiUrls.bannersUrl(screenName),
        showResponse: false,
      );

      if (response != null) {
        print("Banner response----: $response");
        final Map<String, dynamic> jsonResponse = response is String ? jsonDecode(response) : response;
        final model = ScreenBannerModel.fromJson(jsonResponse);
        if (model.status == true) {
          screenBanners[screenName] = model;
          screenBanners.refresh();
          return model;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching banners for $screenName: $e");
      }
    } finally {
      loadingScreens[screenName] = false;
      loadingScreens.refresh();
    }
    return screenBanners[screenName];
  }
}
