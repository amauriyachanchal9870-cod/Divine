import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/wallet_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var walletBalance = 0.0.obs;
  var transactions = <WalletTransaction>[].obs;
  var errorMessage = ''.obs;
  var searchQuery = ''.obs;
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

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
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
          walletBalance.value = model.data!.walletBalance ?? 0.0;
          transactions.value = model.data!.transactions ?? [];
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
      isLoading.value = false;
    }
  }
}
