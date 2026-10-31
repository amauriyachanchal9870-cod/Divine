import 'dart:convert';
import 'package:get/get.dart';
import '../Model/home_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

import '../Controller/banner_controller.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var homeData = Rxn<HomeData>();
  var errorMessage = ''.obs;

  var isDonationHistoryLoading = false.obs;
  var donationHistoryList = <HomeDonationHistory>[].obs;
  var hasFetchedDonationHistory = false.obs;

  var isDonorNgosLoading = false.obs;
  var donorNgosList = <HomeNgo>[].obs;
  var hasFetchedDonorNgos = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<BannerController>()) {
      Get.put(BannerController());
    }
    fetchHomeData();
  }

  Future<void> fetchDonorNgos() async {
    try {
      isDonorNgosLoading.value = true;

      final response = await Repositories().getApi(
        url: ApiUrls.donorNgosUrl,
        showResponse: true,
      );

      if (response != null) {
        print("========================================");
        print("DONOR NGOS API RESPONSE: $response");
        print("========================================");
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final list = (jsonResponse['data'] as List)
              .map((e) => HomeNgo.fromJson(e))
              .toList();
          donorNgosList.value = list;
        } else {
          donorNgosList.clear();
        }
      } else {
        donorNgosList.clear();
      }
    } catch (e) {
      print("Error fetching donor ngos: $e");
      donorNgosList.clear();
    } finally {
      hasFetchedDonorNgos.value = true;
      isDonorNgosLoading.value = false;
    }
  }

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && homeData.value != null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (Get.isRegistered<BannerController>()) {
        Get.find<BannerController>().fetchBanners('home', forceRefresh: forceRefresh);
      }

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

  void clearData() {
    homeData.value = null;
    donationHistoryList.clear();
    hasFetchedDonationHistory.value = false;
    donorNgosList.clear();
    hasFetchedDonorNgos.value = false;
    errorMessage.value = '';
    selectedDonationFilter.value = 'All';
    selectedDonationType.value = 'All';
    donationStartDate.value = null;
    donationEndDate.value = null;
    donationSearchQuery.value = '';
  }

  Future<void> fetchDonationHistory() async {
    try {
      isDonationHistoryLoading.value = true;
      hasFetchedDonationHistory.value = false;
      donationHistoryList.clear();

      final response = await Repositories().getApi(
        url: ApiUrls.donationHistoryUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final list = (jsonResponse['data'] as List)
              .map((e) => HomeDonationHistory.fromJson(e))
              .toList();
          donationHistoryList.value = list;
        } else {
          donationHistoryList.clear();
        }
      } else {
        donationHistoryList.clear();
      }
    } catch (e) {
      donationHistoryList.clear();
    } finally {
      hasFetchedDonationHistory.value = true;
      isDonationHistoryLoading.value = false;
    }
  }

  List<HomeBanner> get banners => homeData.value?.banners ?? [];
  List<HomeCampaign> get campaigns => homeData.value?.campaigns ?? [];
  List<HomeNgo> get ngos {
    if (hasFetchedDonorNgos.value) {
      return donorNgosList;
    }
    if (donorNgosList.isNotEmpty) {
      return donorNgosList;
    }
    return homeData.value?.ngos ?? [];
  }
  List<HomeDonationHistory> get homeDonationHistory {
    final list = homeData.value?.donationHistory;
    if (list != null && list.isNotEmpty) {
      return list;
    }
    return donationHistoryList;
  }

  List<HomeDonationHistory> get donationHistory {
    if (hasFetchedDonationHistory.value) {
      return donationHistoryList;
    }
    if (donationHistoryList.isNotEmpty) {
      return donationHistoryList;
    }
    return homeData.value?.donationHistory ?? [];
  }
  int get totalDonateAmount => homeData.value?.totalDonateAmount ?? 0;
  HomeUser? get user => homeData.value?.user;
  List<HomeCategory> get categories => homeData.value?.categories ?? [];
  List<HomePressMedia> get pressAndMedia => homeData.value?.pressAndMedia ?? [];

  var selectedDonationFilter = 'All'.obs;
  var selectedDonationType = 'All'.obs; // Options: 'All', 'Campaign', 'Daan'
  var donationStartDate = Rxn<DateTime>();
  var donationEndDate = Rxn<DateTime>();
  var donationSearchQuery = ''.obs;

  void setDonationDateRange(DateTime? start, DateTime? end) {
    donationStartDate.value = start;
    donationEndDate.value = end;
  }

  void clearDonationDateRange() {
    donationStartDate.value = null;
    donationEndDate.value = null;
  }

  void clearAllDonationFilters() {
    selectedDonationFilter.value = 'All';
    selectedDonationType.value = 'All';
    donationStartDate.value = null;
    donationEndDate.value = null;
    donationSearchQuery.value = '';
  }

  bool get hasActiveDonationFilters {
    return selectedDonationType.value != 'All' ||
        donationStartDate.value != null ||
        donationEndDate.value != null ||
        donationSearchQuery.value.trim().isNotEmpty ||
        selectedDonationFilter.value != 'All';
  }

  List<HomeDonationHistory> get filteredDonationHistory {
    final list = donationHistory;
    final filter = selectedDonationFilter.value;
    final typeFilter = selectedDonationType.value;
    final query = donationSearchQuery.value.trim().toLowerCase();

    List<HomeDonationHistory> result = list;

    // 1. Filter by Donation Type (Campaign vs Daan vs NGO)
    if (typeFilter == 'Campaign') {
      result = result.where((t) => t.isCampaign).toList();
    } else if (typeFilter == 'Daan') {
      result = result.where((t) => t.isDaan).toList();
    } else if (typeFilter == 'NGO') {
      result = result.where((t) => t.isNgo).toList();
    }

    // 2. Filter by Date Range (Start Date to End Date)
    if (donationStartDate.value != null) {
      final s = donationStartDate.value!;
      final startDay = DateTime(s.year, s.month, s.day, 0, 0, 0);
      result = result.where((t) {
        final d = t.parsedDate;
        if (d == null) return false;
        return !d.isBefore(startDay);
      }).toList();
    }

    if (donationEndDate.value != null) {
      final e = donationEndDate.value!;
      final endDay = DateTime(e.year, e.month, e.day, 23, 59, 59, 999);
      result = result.where((t) {
        final d = t.parsedDate;
        if (d == null) return false;
        return !d.isAfter(endDay);
      }).toList();
    }

    // 3. Tab filter (Payment Logs, Cashback, Expiry Cashback)
    if (filter == 'Payment Logs') {
      result = result.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        final statusLower = (t.status ?? '').toLowerCase();
        return itemLower.contains('top') ||
               itemLower.contains('wallet') ||
               itemLower.contains('pay') ||
               itemLower.contains('log') ||
               itemLower.contains('donation') ||
               statusLower.contains('completed') ||
               statusLower.contains('success');
      }).toList();
    } else if (filter == 'Cashback') {
      result = result.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        return itemLower.contains('cashback') || itemLower.contains('reward');
      }).toList();
    } else if (filter == 'Expiry Cashback') {
      result = result.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        return itemLower.contains('expiry') || itemLower.contains('bonus');
      }).toList();
    }

    // 4. Search Query Filter
    if (query.isNotEmpty) {
      result = result.where((t) {
        final item = (t.item ?? '').toLowerCase();
        final donor = (t.donor ?? '').toLowerCase();
        final status = (t.status ?? '').toLowerCase();
        final date = (t.date ?? '').toLowerCase();
        final amount = (t.amount ?? 0).toString();
        return item.contains(query) ||
               donor.contains(query) ||
               status.contains(query) ||
               date.contains(query) ||
               amount.contains(query);
      }).toList();
    }

    return result;
  }
}
