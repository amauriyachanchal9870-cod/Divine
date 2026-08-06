import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/home_controller.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  void _showFilterBottomSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = ['All', 'Payment Logs', 'Cashback', 'Expiry Cashback'];
        return Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filter Donations",
                      style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  bool isSelected = controller.selectedDonationFilter.value == option;
                  return InkWell(
                    onTap: () {
                      controller.selectedDonationFilter.value = option;
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: AppFonts.mediumText.copyWith(
                              fontSize: 15,
                              color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: AppTheme.primaryDeepBlue, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.selectedDonationFilter.value = 'All';
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.donationHistory.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context, homeController),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.fieldBorderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 14, color: AppTheme.textGrey500),
                  const SizedBox(width: 4),
                  Text(
                    "Filter",
                    style: AppFonts.mediumText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final history = homeController.filteredDonationHistory;
        final totalDonations = homeController.donationHistory.fold<int>(0, (sum, item) => sum + (item.amount ?? 0));
        // Count unique campaign items supported
        final campaignsSupported = homeController.donationHistory.map((e) => e.item).where((item) => item != null && item.isNotEmpty).toSet().length;

        if (history.isEmpty) {
          return Center(
            child: Text(
              "No donation history found",
              style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTotalDonationSummary(campaignsSupported, totalDonations),
                const SizedBox(height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final txn = history[index];
                    return _buildHistoryItem(txn);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTotalDonationSummary(int campaigns, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$campaigns", style: AppFonts.titleStyle.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text("Campaigns Supported", style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
            ],
          ),
          Container(height: 40, width: 1, color: AppTheme.fieldBorderColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${formatPrice(totalAmount)}", style: AppFonts.titleStyle.copyWith(fontSize: 20, color: AppTheme.primaryDeepBlue)),
              const SizedBox(height: 4),
              Text(AppString.totalDonations.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HomeDonationHistory txn) {
    final title = txn.item ?? 'Donation';
    final subtitle = txn.donor != null ? 'by ${txn.donor}' : (txn.status ?? '');
    
    String displayDate = txn.date ?? '';
    if (displayDate.length > 10) {
      displayDate = displayDate.substring(0, 10);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (title.isNotEmpty ? title[0] : '?').toUpperCase(),
                style: TextStyle(color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayDate, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400)),
              const SizedBox(height: 4),
              Text(
                "₹${formatPrice(txn.amount ?? 0)}",
                style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: AppTheme.progressGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
