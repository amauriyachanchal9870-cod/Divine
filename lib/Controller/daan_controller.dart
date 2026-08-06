import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/dan_categories_model.dart';
import '../Model/dan_subcategories_model.dart';
import '../Model/dan_items_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class DaanController extends GetxController {
  // Cart items quantity state
  var rationKitQty = 2.obs;
  var feedBrahminsQty = 0.obs;
  var dryRationsQty = 1.obs;

  // Pricing constants
  final int rationKitPrice = 300;
  final int feedBrahminsPrice = 300;
  final int dryRationsPrice = 200;

  // Selected Impact type: 'one_time' or 'monthly'
  var impactType = 'one_time'.obs;

  // Event Details
  var selectedEvent = 'Others'.obs; // Default to Others as shown in screenshot
  var eventName = ''.obs;
  var eventDate = ''.obs;
  var selectedCurrency = 'INR'.obs;
  var addDetailsChecked = true.obs;

  // API State
  var isLoading = false.obs;
  var categories = <DanCategoryData>[].obs;
  var topBanners = <DanBannerItem>[].obs;
  var bottomBanners = <DanBannerItem>[].obs;
  var searchQuery = ''.obs;
  var errorMessage = ''.obs;

  // Subcategory State
  var subCategoryLoading = false.obs;
  var subCategories = <DanSubCategoryData>[].obs;
  var subCategoryError = ''.obs;

  // Items State
  var itemsLoading = false.obs;
  var danItems = <DanItemData>[].obs;
  var itemsError = ''.obs;
  var isSubmitting = false.obs;
  // per-item quantity map: itemId -> qty
  final itemQtyMap = <String, int>{}.obs;

  // Dynamic total from items cart
  int get itemsTotal {
    int total = 0;
    for (final item in danItems) {
      final qty = itemQtyMap[item.id ?? ''] ?? 0;
      total += qty * (item.price?.toInt() ?? 0);
    }
    return total;
  }

  // Cart items with qty > 0
  List<Map<String, dynamic>> get cartPayload {
    final List<Map<String, dynamic>> payload = [];
    for (final item in danItems) {
      final qty = itemQtyMap[item.id ?? ''] ?? 0;
      if (qty > 0) {
        payload.add({"itemId": item.id, "quantity": qty});
      }
    }
    return payload;
  }

  void incrementItem(String itemId) {
    itemQtyMap[itemId] = (itemQtyMap[itemId] ?? 0) + 1;
  }

  void decrementItem(String itemId) {
    final current = itemQtyMap[itemId] ?? 0;
    if (current > 0) itemQtyMap[itemId] = current - 1;
  }

  Future<bool> submitDaanDonation({
    required BuildContext context,
    required String donorName,
    required String donorPhone,
    required String donorEmail,
  }) async {
    try {
      isSubmitting.value = true;

      // Format event date for API: convert dd/MM/yyyy -> yyyy-MM-dd
      String formattedDate = '';
      if (eventDate.value.isNotEmpty) {
        try {
          final parts = eventDate.value.split('/');
          if (parts.length == 3) {
            formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
          }
        } catch (_) {}
      }

      final Map<String, dynamic> body = {
        "donorName": donorName,
        "donorPhone": donorPhone,
        "donorEmail": donorEmail,
        "frequency": impactType.value == 'monthly' ? "Monthly" : "One-Time",
        "eventType": selectedEvent.value,
        "eventName": addDetailsChecked.value ? eventName.value : "",
        "eventDate": addDetailsChecked.value ? formattedDate : "",
        "paymentMethod": "Wallet",
        "items": cartPayload,
      };

      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.danDonateUrl,
        mapData: body,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error submitting daan donation: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Total calculation
  int get totalAmount {
    int total = 0;
    total += rationKitQty.value * rationKitPrice;
    total += feedBrahminsQty.value * feedBrahminsPrice;
    total += dryRationsQty.value * dryRationsPrice;
    return total;
  }

  // Count items
  int get saintsBrahminsItemCount => rationKitQty.value + feedBrahminsQty.value;
  int get saintsBrahminsTotal => (rationKitQty.value * rationKitPrice) + (feedBrahminsQty.value * feedBrahminsPrice);

  int get dryRationsItemCount => dryRationsQty.value;
  int get dryRationsTotal => dryRationsQty.value * dryRationsPrice;

  List<DanCategoryData> get filteredCategories {
    if (searchQuery.value.isEmpty) return categories;
    return categories.where((c) {
      return c.name?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDaanCategories();
  }

  Future<void> fetchDaanCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.danCategoriesUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = DanCategoriesModel.fromJson(jsonResponse);
        if (model.status == true) {
          categories.value = model.data ?? [];
          topBanners.value = model.banners?.top ?? [];
          bottomBanners.value = model.banners?.bottom ?? [];
        } else {
          errorMessage.value = 'Failed to load daan categories.';
        }
      } else {
        errorMessage.value = 'No response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint("Error fetching daan categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDaanSubCategories(String categoryId) async {
    try {
      subCategoryLoading.value = true;
      subCategoryError.value = '';
      subCategories.clear();

      final response = await Repositories().getApi(
        url: ApiUrls.danSubCategoriesUrl(categoryId),
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = DanSubCategoriesModel.fromJson(jsonResponse);
        if (model.status == true) {
          subCategories.value = model.data ?? [];
        } else {
          subCategoryError.value = 'Failed to load subcategories.';
        }
      } else {
        subCategoryError.value = 'No response from server.';
      }
    } catch (e) {
      subCategoryError.value = 'Error: ${e.toString()}';
      debugPrint("Error fetching daan subcategories: $e");
    } finally {
      subCategoryLoading.value = false;
    }
  }

  Future<void> fetchDaanItems(String subcategoryId) async {
    try {
      itemsLoading.value = true;
      itemsError.value = '';
      danItems.clear();
      itemQtyMap.clear();

      final response = await Repositories().getApi(
        url: ApiUrls.danItemsUrl(subcategoryId),
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = DanItemsModel.fromJson(jsonResponse);
        if (model.status == true) {
          danItems.value = model.data ?? [];
          // initialise qty to 0 for each item
          for (final item in danItems) {
            if (item.id != null) itemQtyMap[item.id!] = 0;
          }
        } else {
          itemsError.value = 'Failed to load items.';
        }
      } else {
        itemsError.value = 'No response from server.';
      }
    } catch (e) {
      itemsError.value = 'Error: ${e.toString()}';
      debugPrint("Error fetching daan items: $e");
    } finally {
      itemsLoading.value = false;
    }
  }

  void resetAll() {
    rationKitQty.value = 2;
    feedBrahminsQty.value = 0;
    dryRationsQty.value = 1;
    impactType.value = 'one_time';
    selectedEvent.value = 'Others';
    eventName.value = '';
    eventDate.value = '';
    selectedCurrency.value = 'INR';
    addDetailsChecked.value = true;
  }
}
