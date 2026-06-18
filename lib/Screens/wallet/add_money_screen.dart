import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController(text: "50");

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
        title: Text(AppString.addMoneyTitle.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
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
                Text(
                  AppString.paymentMethod.tr,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildTopPaymentMethods(),
                const SizedBox(height: 16),
                _buildOtherPaymentMethods(),
                const SizedBox(height: 32),
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
                    onPressed: () {
                      // Logic to process payment
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
    List<String> amounts = ["50", "100", "500", "1000", "2000", "5000"];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amounts.map((amount) {
        bool isSelected = _amountController.text == amount;
        return GestureDetector(
          onTap: () => _setAmount(amount),
          child: Container(
            width: (MediaQuery.of(context).size.width - 40 - 24) / 3, // 3 columns, 12 spacing
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
              border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "₹ $amount",
              style: AppFonts.mediumText.copyWith(
                color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
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
