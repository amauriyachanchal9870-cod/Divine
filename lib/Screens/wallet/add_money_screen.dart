import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/wallet_controller.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/helper.dart';
import '../../Routes/my_routes.dart';
import '../../Services/razorpay_service.dart';
import '../dashboard/main_navigation_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  late final WalletController _walletController;
  final TextEditingController _amountController = TextEditingController(text: "100");
  late final RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());
    if (!_walletController.hasFetched.value) {
      _walletController.fetchWalletData();
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(String amount) {
    setState(() {
      _amountController.text = amount;
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
        title: Text("Recharge", style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.enterAmount.tr,
                  style: AppFonts.titleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  AppString.topUpWalletDesc.tr,
                  style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500, fontSize: 13),
                ),
                const SizedBox(height: 24),
                _buildAmountInput(),
                const SizedBox(height: 24),
                Text(
                  AppString.chooseAmount.tr,
                  style: AppFonts.mediumText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 16),
                _buildAmountChips(),
                const SizedBox(height: 32),
                // Text(
                //   AppString.paymentMethod.tr,
                //   style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                // ),
                // const SizedBox(height: 16),
                // _buildTopPaymentMethods(),
                // const SizedBox(height: 16),
                // _buildOtherPaymentMethods(),
                // const SizedBox(height: 32),
                Text(
                  AppString.paymentSummary.tr,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildPaymentSummary(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final double? amount = double.tryParse(_amountController.text);
                      if (amount == null || amount <= 0) {
                        showSnackBar("Please enter a valid amount.", false);
                        return;
                      }
                      if (amount < 50) {
                        showSnackBar("Amount should be more than 50rs", false);
                        return;
                      }
                      if (amount > 100000) {
                        showSnackBar("Amount should be less than 100000rs", false);
                        return;
                      }

                      final profile = _profileController.profileData.value;
                      _razorpayService.openCheckout(
                        amountInRupees: amount,
                        description: "Wallet Top-up",
                        userEmail: profile?.email ?? '',
                        userPhone: profile?.phone ?? '',
                        onSuccess: (response) async {
                          if (!mounted) return;
                          final success = await _profileController.topupWallet(context, amount);
                          if (success) {
                            final walletController = Get.isRegistered<WalletController>()
                                ? Get.find<WalletController>()
                                : Get.put(WalletController());
                            await walletController.fetchWalletData(forceRefresh: true);

                            if (mainNavKey.currentState != null) {
                              mainNavKey.currentState?.changeTab(3);
                              if (mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            } else {
                              Get.offAllNamed(MyRouters.mainNav, arguments: 3);
                            }
                          }
                        },
                        onFailure: (response) {
                          showSnackBar(response.message ?? "Payment Failed. Please try again.", false);
                        },
                      );
                    },
                    child: Text(
                      AppString.securelyAddMoney.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            "₹ ",
            style: AppFonts.titleStyle.copyWith(fontSize: 32, color: AppTheme.primaryDeepBlue),
          ),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ],
              style: AppFonts.titleStyle.copyWith(fontSize: 32, color: AppTheme.primaryDeepBlue),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChips() {
    return Obx(() {
      final tiers = _walletController.rechargeTiers;
      if (tiers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tiers.map((tier) {
          final int amount = tier.amount ?? 0;
          final String amountStr = amount.toString();
          final bool isSelected = _amountController.text == amountStr;
          final int cashback = tier.cashback ?? 0;
          final int coins = tier.bonusCoins ?? 0;

          return GestureDetector(
            onTap: () => _setAmount(amountStr),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: (MediaQuery.of(context).size.width - 40 - 24) / 3, // 3 columns, 12 spacing
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.08) : Colors.white,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
                  width: isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryDeepBlue.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top: Cashback Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryDeepBlue.withValues(alpha: 0.12)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "₹$cashback Cashback",
                        style: AppFonts.semiBoldText.copyWith(
                          fontSize: 10,
                          color: isSelected
                              ? AppTheme.primaryDeepBlue
                              : const Color(0xFF2E7D32),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Middle: Amount
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "₹ $amountStr",
                      style: AppFonts.semiBoldText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bottom: Cashback Coins
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 13,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "+$coins Coins",
                          style: AppFonts.mediumText.copyWith(
                            fontSize: 11,
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildTopPaymentMethods() {
    return Row(
      children: [
        Expanded(child: _buildPayMethodBox("Apple Pay", Icons.phone_iphone)),
        const SizedBox(width: 12),
        Expanded(child: _buildPayMethodBox("G Pay", Icons.g_mobiledata, iconColor: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildPayMethodBox("PayPal", Icons.payment, iconColor: Colors.indigo)),
      ],
    );
  }

  Widget _buildPayMethodBox(String name, IconData icon, {Color iconColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: iconColor),
          if (name != "Apple Pay" && name != "G Pay" && name != "PayPal") ...[
            const SizedBox(width: 4),
            Text(name, style: AppFonts.mediumText.copyWith(fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _buildOtherPaymentMethods() {
    return Column(
      children: [
        _buildListPaymentMethod(Icons.account_balance, AppString.netBanking.tr),
        const SizedBox(height: 12),
        _buildListPaymentMethod(Icons.account_balance_wallet, AppString.otherWallets.tr),
      ],
    );
  }

  Widget _buildListPaymentMethod(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textGrey500),
          const SizedBox(width: 12),
          Text(title, style: AppFonts.mediumText.copyWith(fontSize: 13)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    String currentAmount = _amountController.text.isEmpty ? "0" : _amountController.text;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppString.subtotal.tr, style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500)),
            Text("₹$currentAmount", style: AppFonts.mediumText.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(AppString.gatewayFee.tr, style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500)),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              ],
            ),
            Text(AppString.free.tr, style: AppFonts.mediumText.copyWith(fontSize: 13, color: AppTheme.progressGreen)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppString.total.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
            Text("₹$currentAmount", style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
