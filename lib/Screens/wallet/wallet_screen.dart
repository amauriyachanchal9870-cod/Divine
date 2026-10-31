import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/wallet_controller.dart';
import '../../Controller/profile_controller.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Utilities/helper.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchWalletData();
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile(context);
      }
    });
  }

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

  String formatWalletAmount(double val) {
    if (val >= 1000) {
      return formatPrice(val);
    }
    return val.toStringAsFixed(2);
  }

  String formatCreditDebitAmount(double val) {
    return formatPrice(val);
  }

  bool _isPositiveTransaction(t) {
    return (t.item?.toLowerCase().contains('cashback') ?? false) || 
           (t.item?.toLowerCase().contains('top') ?? false) || 
           (t.item?.toLowerCase().contains('wallet') ?? false) ||
           (t.type?.toLowerCase() == 'credit') ||
           (t.type?.toLowerCase() == 'topup');
  }

  void _showFilterBottomSheet(BuildContext context) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppString.wallet.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchWalletData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildBalanceCard(),
                const SizedBox(height: 16),
                _buildCashbackCard(),
                const SizedBox(height: 16),
                _buildCoinsCard(),
                const SizedBox(height: 20),
                _buildTogglePill(),
                const SizedBox(height: 20),
                _buildCreditDebitSection(),
                const SizedBox(height: 24),
                _buildTransactionsHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value && controller.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: LoadingAnimationWidget.threeRotatingDots(
                          color: AppTheme.primaryDeepBlue,
                          size: 40,
                        ),
                      ),
                    );
                  }

                  final items = controller.filteredTransactions;
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          "No transactions found.",
                          style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400),
                        ),
                      ),
                    );
                  }

                  final displayItems = items.take(4).toList();

                  return Column(
                    children: [
                      ...displayItems.map((t) {
                        bool isPositive = _isPositiveTransaction(t);
                        String formattedVal = formatPrice(t.amount ?? 0);
                        String amtStr = "${isPositive ? "+" : "-"}₹$formattedVal";
                        String? expiryStr;
                        if (t.item?.toLowerCase().contains('apple') ?? false) {
                          expiryStr = "Expiry: 14 Jan 2027";
                        }
                        String? bonusStr;
                        // if (isPositive && (t.amount ?? 0) >= 1000) {
                        //   bonusStr = "+150 bonus";
                        // }

                        return _buildTransactionItem(
                          t.item ?? "Transaction",
                          formatDate(t.date),
                          amtStr,
                          isPositive ? "topup" : "donation",
                          subtitle: expiryStr,
                          extra: bonusStr,
                        );
                      }),
                      const SizedBox(height: 12),
                      _buildViewAllButton(),
                    ],
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(() {
      double bal = controller.walletBalance.value;
      if (bal == 0.0 && Get.isRegistered<ProfileController>()) {
        final pBal = Get.find<ProfileController>().profileData.value?.walletBalance;
        if (pBal != null && pBal > 0) {
          bal = pBal;
        }
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(20),
        //   border: Border.all(color: AppTheme.fieldBorderColor),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withValues(alpha: 0.02),
        //       blurRadius: 10,
        //       offset: const Offset(0, 4),
        //     ),
        //   ],
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available Balance",
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹ ${formatWalletAmount(bal)}",
                  style: AppFonts.titleStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(MyRouters.addMoneyScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeepBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                "Recharge",
                style: AppFonts.semiBoldText.copyWith(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCashbackCard() {
    return Obx(() {
      double totalCashback = controller.cashbackBalance.value > 0
          ? controller.cashbackBalance.value
          : controller.transactions
              .where((t) => t.item?.toLowerCase().contains('cashback') ?? false)
              .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.fieldBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.percent, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.cashbackEarned.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                  ),
                  Text(
                    AppString.totalLifetimeRewards.tr,
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                ],
              ),
            ),
            Text(
              "₹${totalCashback.toStringAsFixed(0)}",
              style: AppFonts.semiBoldText.copyWith(color: Colors.blue, fontSize: 16),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCoinsCard() {
    return Obx(() {
      int coins = controller.totalCoins.value;
      double valueInRupees = controller.coinsValueInRupees.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.fieldBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.monetization_on_outlined, color: Colors.amber[700], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.totalCoins.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                  ),
                  Text(
                    "Value in Rupees: ₹${valueInRupees.toStringAsFixed(2)}",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                ],
              ),
            ),
            Text(
              "$coins",
              style: AppFonts.semiBoldText.copyWith(color: Colors.amber[800], fontSize: 16),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTogglePill() {
    return Obx(() {
      bool isDonations = controller.selectedTab.value == 'Donations';

      return Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 'Donations',
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDonations ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Text(
                    "Donations",
                    style: AppFonts.mediumText.copyWith(
                      color: isDonations ? Colors.white : AppTheme.textGrey500,
                      fontSize: 14,
                      fontWeight: isDonations ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 'Fundraising',
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isDonations ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Text(
                    "Fundraising",
                    style: AppFonts.mediumText.copyWith(
                      color: !isDonations ? Colors.white : AppTheme.textGrey500,
                      fontSize: 14,
                      fontWeight: !isDonations ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCreditDebitSection() {
    return Obx(() {
      double credits = controller.transactions
          .where((t) => _isPositiveTransaction(t))
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      double debits = controller.transactions
          .where((t) => !_isPositiveTransaction(t))
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));

      return Row(
        children: [
          Expanded(
            child: _buildCreditDebitBox(
              icon: Icons.south_west,
              iconColor: Colors.green,
              title: AppString.credits.tr,
              amount: "₹${formatCreditDebitAmount(credits)}",
              subtitle: AppString.moneyReceived.tr,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCreditDebitBox(
              icon: Icons.north_east,
              iconColor: Colors.red,
              title: AppString.debits.tr,
              amount: "₹${formatCreditDebitAmount(debits)}",
              subtitle: AppString.moneySpent.tr,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCreditDebitBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(title, style: AppFonts.mediumText.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(amount, style: AppFonts.titleStyle.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppString.transactions.tr,
          style: AppFonts.semiBoldText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
          child: Container(
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
    );
  }

  Widget _buildSearchBar() {
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

  Widget _buildViewAllButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          Get.toNamed(MyRouters.transactionsScreen);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.fieldBorderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(
          "View all",
          style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
}
