import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedCardIndex = 0;
  int _selectedMoreOption = -1; // -1 = none, 0 = net banking, 1 = other wallets

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
        title: Text(AppString.paymentMethod.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaxNotice(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(AppString.upiPayments.tr),
                  const SizedBox(height: 12),
                  _buildUPIOptions(),
                  const SizedBox(height: 12),
                  _buildAddButton(AppString.addUpi.tr),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppString.creditDebitAtmCard.tr),
                  const SizedBox(height: 12),
                  _buildCardOptions(),
                  const SizedBox(height: 12),
                  _buildAddButton(AppString.addCard.tr),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppString.moreOptions.tr),
                  const SizedBox(height: 12),
                  _buildMoreOptions(),
                  const SizedBox(height: 32),
                  _buildSecurityFooter(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTaxNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.taxNoticeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryDeepBlue.withValues(alpha: 0.15)),
      ),
      child: Text(
        AppString.taxExemptNotice.tr,
        style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.primaryDeepBlue, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87));
  }

  Widget _buildUPIOptions() {
    return Row(
      children: [
        _buildUPIBox(Icons.apple, "Pay"),
        const SizedBox(width: 10),
        _buildUPIBox(Icons.g_mobiledata, "Pay"),
        const SizedBox(width: 10),
        _buildUPIBox(Icons.paypal_outlined, "PayPal"),
      ],
    );
  }

  Widget _buildUPIBox(IconData icon, String text) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(text, style: AppFonts.semiBoldText.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String text) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(text, style: AppFonts.semiBoldText.copyWith(color: AppTheme.primaryDeepBlue, fontSize: 14)),
      ),
    );
  }

  Widget _buildCardOptions() {
    final cards = [
      {'name': 'Mastercard ****6548', 'color': AppTheme.mastercardOrange, 'icon': Icons.credit_card},
      {'name': 'Visa ****6548', 'color': AppTheme.visaBlue, 'icon': Icons.credit_card},
    ];

    return Column(
      children: List.generate(cards.length, (index) {
        final isSelected = _selectedCardIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCardIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 20,
                  decoration: BoxDecoration(
                    color: (cards[index]['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(cards[index]['icon'] as IconData, color: cards[index]['color'] as Color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(cards[index]['name'] as String, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMoreOptions() {
    return Column(
      children: [
        _buildMoreOptionTile(
          icon: Icons.account_balance_outlined,
          title: AppString.netBanking.tr,
          index: 0,
        ),
        const SizedBox(height: 12),
        _buildMoreOptionTile(
          icon: Icons.account_balance_wallet_outlined,
          title: AppString.otherWallets.tr,
          index: 1,
        ),
      ],
    );
  }

  Widget _buildMoreOptionTile({required IconData icon, required String title, required int index}) {
    final isSelected = _selectedMoreOption == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoreOption = isSelected ? -1 : index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 14))),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, color: AppTheme.progressGreen, size: 16),
        const SizedBox(width: 6),
        Text(AppString.safeAndSecurePayment.tr, style: AppFonts.regularText.copyWith(color: AppTheme.progressGreen, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomBar() {
    final String amount = Get.arguments?['amount'] ?? '250';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Get.toNamed(MyRouters.paymentSuccessScreen);
            },
            child: Text("${AppString.pay.tr} ₹$amount", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
