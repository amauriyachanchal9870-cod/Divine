import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Model/home_model.dart';
import '../../Services/donation_receipt_service.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/helper.dart';

class DonationDetailsScreen extends StatelessWidget {
  final HomeDonationHistory? donation;

  const DonationDetailsScreen({super.key, this.donation});

  @override
  Widget build(BuildContext context) {
    final txn = donation ?? (Get.arguments is HomeDonationHistory ? Get.arguments as HomeDonationHistory : null);

    if (txn == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text("Donation Details", style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        ),
        body: const Center(
          child: Text("No donation details found"),
        ),
      );
    }

    final isDaan = txn.isDaan;
    final isNgo = txn.isNgo;
    final typeLabel = isDaan ? 'Daan' : (isNgo ? 'NGO' : 'Campaign');
    final amount = txn.amount ?? 0;
    final status = txn.status ?? 'Success';
    final isSuccess = status.toLowerCase() == 'success';

    String displayDate = txn.date ?? '';
    if (txn.parsedDate != null) {
      displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(txn.parsedDate!);
    } else if (displayDate.length > 10) {
      displayDate = displayDate.substring(0, 10);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Donation Details",
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.primaryDeepBlue),
            tooltip: "Download Receipt",
            onPressed: () => DonationReceiptService.downloadReceipt(txn),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Status & Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.fieldBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "₹${formatPrice(amount)}",
                    style: AppFonts.titleStyle.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDeepBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSuccess ? Icons.verified_rounded : Icons.access_time_rounded,
                          size: 13,
                          color: isSuccess ? const Color(0xFF15803D) : const Color(0xFFB45309),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSuccess ? "Donation Successful" : status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSuccess ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayDate,
                    style: AppFonts.regularText.copyWith(
                      fontSize: 12,
                      color: AppTheme.textGrey500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contribution Details Card
            Text(
              "Donation Information",
              style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.fieldBorderColor),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: "Cause / Item",
                    valueWidget: Text(
                      txn.item ?? 'Noble Cause',
                      style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const Divider(height: 22, thickness: 0.8),
                  _buildDetailRow(
                    label: "Donation Type",
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDaan
                            ? const Color(0xFFFEF3C7)
                            : (isNgo ? const Color(0xFFEDE9FE) : const Color(0xFFE0F2FE)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDaan
                              ? const Color(0xFFB45309)
                              : (isNgo ? const Color(0xFF6D28D9) : const Color(0xFF0369A1)),
                        ),
                      ),
                    ),
                  ),
                  if (txn.donor != null && txn.donor!.isNotEmpty) ...[
                    const Divider(height: 22, thickness: 0.8),
                    _buildDetailRow(
                      label: "Donor Name",
                      valueWidget: Text(
                        txn.donor!,
                        style: AppFonts.mediumText.copyWith(fontSize: 13, color: Colors.black87),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                  if (txn.transactionId != null && txn.transactionId!.isNotEmpty) ...[
                    const Divider(height: 22, thickness: 0.8),
                    _buildDetailRow(
                      label: "Transaction ID",
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            txn.transactionId!,
                            style: AppFonts.mediumText.copyWith(
                              fontSize: 12,
                              color: AppTheme.primaryDeepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: txn.transactionId!));
                              showSnackBar("Transaction ID copied to clipboard", true);
                            },
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (txn.fundCategory != null && txn.fundCategory!.isNotEmpty) ...[
                    const Divider(height: 22, thickness: 0.8),
                    _buildDetailRow(
                      label: "Category",
                      valueWidget: Text(
                        txn.fundCategory!,
                        style: AppFonts.mediumText.copyWith(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                  const Divider(height: 22, thickness: 0.8),
                  _buildDetailRow(
                    label: "Organization",
                    valueWidget: Text(
                      "Divine Foundation",
                      style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 80G Tax Exemption Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF1D4ED8), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "80G Tax Exemption Eligible",
                          style: AppFonts.semiBoldText.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "This donation qualifies for a 50% deduction under Section 80G of the Income Tax Act. Download and keep this receipt for tax return filing.",
                          style: AppFonts.regularText.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF3B82F6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Download & Share Actions
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => DonationReceiptService.downloadReceipt(txn),
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Download Receipt (PDF)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDeepBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => DonationReceiptService.downloadReceipt(txn, shareDirectly: true),
                icon: Icon(Icons.share_rounded, size: 18, color: AppTheme.primaryDeepBlue),
                label: Text(
                  "Share Receipt",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDeepBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryDeepBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget valueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
        ),
        const SizedBox(width: 12),
        Flexible(child: valueWidget),
      ],
    );
  }
}
