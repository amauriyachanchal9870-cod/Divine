import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.transactions.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildTransactionItem("Donation to Animal Rescue", "Oct 24, 2025 • 14:30", "-₹50", "donation"),
              _buildTransactionItem("Top up via Apple Pay", "Oct 22, 2025 • 09:15", "+₹1,000", "topup", extra: "+150 bonus"),
              _buildTransactionItem("Ocean Cleanup Project", "15 Oct 2025 • 10:30 AM", "+₹100", "donation"),
              _buildTransactionItem("Donation to Animal Rescue", "Oct 24, 2023 • 14:30", "-₹950", "donation"),
              _buildTransactionItem("Top up via Apple Pay", "Oct 22, 2023 • 09:15", "+₹1,000", "topup", extra: "+150 bonus"),
              _buildTransactionItem("Ocean Cleanup Project", "15 Oct 2023 • 10:30 AM", "+₹100", "donation"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppString.searchForCampaigns.tr,
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, String type, {String? extra}) {
    bool isPositive = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type == 'donation' ? Icons.favorite_border : Icons.account_balance_wallet_outlined,
              color: type == 'donation' ? Colors.orange : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppFonts.semiBoldText.copyWith(
                  fontSize: 14,
                  color: isPositive ? AppTheme.progressGreen : Colors.black,
                ),
              ),
              if (extra != null) ...[
                const SizedBox(height: 4),
                Text(extra, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.progressGreen)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
