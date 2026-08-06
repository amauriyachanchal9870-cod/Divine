import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/wallet_controller.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Utilities/helper.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Oct 24, 2025 • 14:30';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      String month = months[dt.month - 1];
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      return "$month ${dt.day}, ${dt.year} • $hour:$minute";
    } catch (e) {
      return dateStr;
    }
  }

  void _showFilterBottomSheet(BuildContext context, WalletController controller) {
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
                      "Filter Transactions",
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
                  bool isSelected = controller.selectedFilter.value == option;
                  return InkWell(
                    onTap: () {
                      controller.selectedFilter.value = option;
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
    final WalletController controller = Get.put(WalletController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
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
        title: Obx(() {
          final tabName = controller.selectedTab.value;
          return Text(
            "$tabName Transactions",
            style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context, controller),
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
        final items = controller.filteredTransactions;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: _buildSearchBar(controller),
            ),
            Expanded(
              child: controller.isLoading.value && items.isEmpty
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: AppTheme.primaryDeepBlue,
                        size: 50,
                      ),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Text(
                            "No transactions found.",
                            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final t = items[index];
                            bool isPositive = (t.item?.toLowerCase().contains('cashback') ?? false) || 
                                              (t.item?.toLowerCase().contains('top') ?? false) || 
                                              (t.item?.toLowerCase().contains('wallet') ?? false) ||
                                              (t.type?.toLowerCase() == 'credit') ||
                                              (t.type?.toLowerCase() == 'topup');
                            String formattedVal = formatPrice(t.amount ?? 0);
                            String amtStr = "${isPositive ? "+" : "-"}₹$formattedVal";
                            String? expiryStr;
                            if (t.item?.toLowerCase().contains('apple') ?? false) {
                              expiryStr = "Expiry: 14 Jan 2027";
                            }
                            String? bonusStr;
                            if (isPositive && (t.amount ?? 0) >= 1000) {
                              bonusStr = "+150 bonus";
                            }

                            return _buildTransactionItem(
                              t.item ?? "Transaction",
                              formatDate(t.date),
                              amtStr,
                              isPositive ? "topup" : "donation",
                              subtitle: expiryStr,
                              extra: bonusStr,
                            );
                          },
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(WalletController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchQuery.value = val;
        },
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    String type, {
    String? subtitle,
    String? extra,
  }) {
    bool isPositive = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                Text(
                  title, 
                  style: AppFonts.mediumText.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(date, style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey400)),
                ],
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
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppTheme.progressGreen : Colors.black,
                ),
              ),
              if (extra != null) ...[
                const SizedBox(height: 2),
                Text(extra, style: AppFonts.mediumText.copyWith(fontSize: 11, color: AppTheme.progressGreen)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
