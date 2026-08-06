import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  int _selectedCardIndex = -2; // -2 = Wallet Payment, 0 = Mastercard, 1 = Visa, etc.
  int _selectedMoreOption = -1; // -1 = none, 0 = net banking, 1 = other wallets

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchProfile(context);
    });
  }

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
                  // _buildTaxNotice(),
                  // const SizedBox(height: 20),
                  _buildSectionTitle("Wallet Payment"),
                  const SizedBox(height: 12),
                  _buildWalletOption(),
                  const SizedBox(height: 24),
                  // Disable UPI Payments section
                  IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(AppString.upiPayments.tr),
                          const SizedBox(height: 12),
                          _buildUPIOptions(),
                          const SizedBox(height: 12),
                          _buildAddButton(AppString.addUpi.tr),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Disable More Options section
                  IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(AppString.moreOptions.tr),
                          const SizedBox(height: 12),
                          _buildMoreOptions(),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildWalletOption() {
    return Obx(() {
      final balance = _profileController.profileData.value?.walletBalance ?? 0.0;
      final isSelected = _selectedCardIndex == -2;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedCardIndex = -2;
            _selectedMoreOption = -1;
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDeepBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet, color: AppTheme.primaryDeepBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Wallet", style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      "Available Balance: ₹${balance.toStringAsFixed(2)}",
                      style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500),
                    ),
                  ],
                ),
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
    });
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
    final String campaignId = Get.arguments?['campaignId'] ?? '';
    final bool isNgo = Get.arguments?['isNgo'] ?? false;

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
            onPressed: () async {
              if (_selectedCardIndex == -2) {
                if (campaignId.isEmpty) {
                  showSnackBar("Invalid campaign.", false);
                  return;
                }
                final double amtVal = double.tryParse(amount) ?? 0.0;
                if (amtVal < 50) {
                  showSnackBar("Amount should be more than 50rs", false);
                  return;
                }
                if (amtVal >= 10000000) {
                  showSnackBar("Amount should be less than 10000000rs", false);
                  return;
                }

                // Check wallet balance
                final balance = _profileController.profileData.value?.walletBalance ?? 0.0;
                if (balance < amtVal) {
                  showSnackBar("Insufficient balance for donate", false);
                  return;
                }

                final success = await _profileController.donateWithWallet(context, campaignId, amtVal, isNgo: isNgo);
                if (success) {
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().fetchHomeData();
                  }
                  Get.toNamed(MyRouters.paymentSuccessScreen);
                }
              } else {
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().fetchHomeData();
                }
                Get.toNamed(MyRouters.paymentSuccessScreen);
              }
            },
            child: Text("${AppString.pay.tr} ₹$amount", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
