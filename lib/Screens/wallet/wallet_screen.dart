import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isOverview = true;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildCashbackCard(),
              const SizedBox(height: 24),
              Text(
                AppString.quickActions.tr,
                style: AppFonts.semiBoldText.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildQuickActionButton(Icons.add, AppString.addMoneyAction.tr, () {
                    Get.toNamed(MyRouters.addMoneyScreen);
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuickActionButton(Icons.history, AppString.transactions.tr, () {
                    Get.toNamed(MyRouters.transactionsScreen);
                  })),
                ],
              ),
              const SizedBox(height: 24),
              _buildSpecialOfferBanner(),
              const SizedBox(height: 24),
              _buildTogglePill(),
              const SizedBox(height: 24),
              if (isOverview) ...[
                _buildOverviewSection(),
              ] else ...[
                _buildTransactionsSection(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.fieldBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.currentBalance.tr,
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ 1775.50",
            style: AppFonts.titleStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackCard() {
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
              color: Colors.blue.withValues(alpha: 0.1),
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
            "₹970",
            style: AppFonts.semiBoldText.copyWith(color: Colors.blue, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.fieldBorderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryDeepBlue, size: 28),
            const SizedBox(height: 12),
            Text(title, style: AppFonts.mediumText.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOfferBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.specialOffer.tr,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  AppString.specialOfferDesc.tr,
                  style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTogglePill() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isOverview = true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOverview ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  AppString.overview.tr,
                  style: AppFonts.mediumText.copyWith(
                    color: isOverview ? Colors.white : AppTheme.textGrey500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isOverview = false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isOverview ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  AppString.transactions.tr,
                  style: AppFonts.mediumText.copyWith(
                    color: !isOverview ? Colors.white : AppTheme.textGrey500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCreditDebitBox(
                icon: Icons.south_west,
                iconColor: Colors.green,
                title: AppString.credits.tr,
                amount: "₹00",
                subtitle: AppString.moneyReceived.tr,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCreditDebitBox(
                icon: Icons.north_east,
                iconColor: Colors.red,
                title: AppString.debits.tr,
                amount: "₹00",
                subtitle: AppString.moneySpent.tr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.recentActivity.tr,
              style: AppFonts.semiBoldText.copyWith(fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(MyRouters.transactionsScreen);
              },
              child: Text(
                AppString.viewAll.tr,
                style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem("Donation to Animal Rescue", "Oct 24, 2025 • 14:30", "-₹50", "donation"),
        _buildTransactionItem("Top up via Apple Pay", "Oct 22, 2025 • 09:15", "+₹1,000", "topup", extra: "+150 bonus"),
        _buildTransactionItem("Ocean Cleanup Project", "15 Oct 2025 • 10:30 AM", "+₹100", "donation"),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.recentTransactions.tr,
              style: AppFonts.semiBoldText.copyWith(fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(MyRouters.transactionsScreen);
              },
              child: Text(
                AppString.viewAll.tr,
                style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem("Donation to Animal Rescue", "Oct 24, 2025 • 14:30", "-₹50", "donation"),
        _buildTransactionItem("Top up via Apple Pay", "Oct 22, 2025 • 09:15", "+₹1,000", "topup", extra: "+150 bonus"),
        _buildTransactionItem("Ocean Cleanup Project", "15 Oct 2025 • 10:30 AM", "+₹100", "donation"),
      ],
    );
  }

  Widget _buildCreditDebitBox({required IconData icon, required Color iconColor, required String title, required String amount, required String subtitle}) {
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

  Widget _buildTransactionItem(String title, String date, String amount, String type, {String? extra}) {
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
