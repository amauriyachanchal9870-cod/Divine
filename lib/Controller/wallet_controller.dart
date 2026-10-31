import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/wallet_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import 'profile_controller.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var walletBalance = 0.0.obs;
  var cashbackBalance = 0.0.obs;
  var totalCoins = 0.obs;
  var coinsValueInRupees = 0.0.obs;
  var transactions = <WalletTransaction>[].obs;
  var errorMessage = ''.obs;
  var searchQuery = ''.obs;
  var rechargeTiers = <RechargeTier>[
    RechargeTier(tierId: "TIER-100", amount: 100, cashback: 10, bonusCoins: 100, badgeText: ""),
    RechargeTier(tierId: "TIER-500", amount: 500, cashback: 50, bonusCoins: 500, badgeText: "Popular"),
    RechargeTier(tierId: "TIER-1000", amount: 1000, cashback: 150, bonusCoins: 1000, badgeText: "Best Value"),
    RechargeTier(tierId: "TIER-2000", amount: 2000, cashback: 400, bonusCoins: 2500, badgeText: "Super Saver"),
    RechargeTier(tierId: "TIER-5000", amount: 5000, cashback: 1200, bonusCoins: 5000, badgeText: "Mega Booster"),
  ].obs;
  var selectedFilter = 'All'.obs; // Options: 'All', 'Payment Logs', 'Cashback', 'Expiry Cashback'
  var selectedTab = 'Donations'.obs; // Options: 'Donations', 'Fundraising'

  List<WalletTransaction> get filteredTransactions {
    List<WalletTransaction> list = transactions;

    if (selectedTab.value == 'Fundraising') {
      list = list.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        final typeLower = (t.type ?? '').toLowerCase();
        return itemLower.contains('fundrais') || itemLower.contains('campaign') || typeLower.contains('fundrais');
      }).toList();
    }

    if (selectedFilter.value == 'Payment Logs') {
      list = list.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        final typeLower = (t.type ?? '').toLowerCase();
        return typeLower == 'topup' || typeLower == 'credit' || itemLower.contains('top') || itemLower.contains('wallet') || itemLower.contains('pay');
      }).toList();
    } else if (selectedFilter.value == 'Cashback') {
      list = list.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        return itemLower.contains('cashback') || itemLower.contains('reward');
      }).toList();
    } else if (selectedFilter.value == 'Expiry Cashback') {
      list = list.where((t) {
        final itemLower = (t.item ?? '').toLowerCase();
        return itemLower.contains('expiry') || itemLower.contains('bonus');
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      list = list.where((t) {
        return t.item?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false;
      }).toList();
    }

    return list;
  }

  var hasFetched = false.obs;

  @override
  void onInit() {
    super.onInit();
    transactions.value = [];
  }

  Future<void> fetchWalletData({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && hasFetched.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.walletUrl,
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = WalletModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          double bal = model.data!.walletBalance ?? 0.0;
          if (bal == 0.0 && Get.isRegistered<ProfileController>()) {
            final pBal = Get.find<ProfileController>().profileData.value?.walletBalance;
            if (pBal != null && pBal > 0) bal = pBal;
          }
          walletBalance.value = bal;
          if (Get.isRegistered<ProfileController>()) {
            final pCtrl = Get.find<ProfileController>();
            if (pCtrl.profileData.value != null) {
              pCtrl.profileData.value!.walletBalance = bal;
              pCtrl.profileData.refresh();
            }
          }
          cashbackBalance.value = model.data!.cashbackBalance ?? 0.0;
          totalCoins.value = model.data!.totalCoins ?? 0;
          coinsValueInRupees.value = model.data!.coinsValueInRupees ?? 0.0;

          List<WalletTransaction> apiTransactions = List<WalletTransaction>.from(model.data!.transactions ?? []);
          // Filter out welcome bonus transactions so no welcome bonus is displayed
          apiTransactions.removeWhere((t) => 
            (t.item ?? '').toLowerCase().contains('welcome bonus') ||
            (t.item ?? '').toLowerCase().contains('welcome')
          );

          transactions.value = apiTransactions;

          final tiersList = model.data!.predefinedRechargeTiers ?? model.data!.rechargeOffers;
          if (tiersList != null && tiersList.isNotEmpty) {
            final activeTiers = tiersList.where((t) => t.isActive != false && (t.amount ?? 0) > 0).toList();
            if (activeTiers.isNotEmpty) {
              rechargeTiers.assignAll(activeTiers);
            }
          }
        } else {
          errorMessage.value = 'Failed to load wallet data.';
        }
      } else {
        errorMessage.value = 'No response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint("Error fetching wallet data: $e");
    } finally {
      hasFetched.value = true;
      isLoading.value = false;
    }
  }
}
