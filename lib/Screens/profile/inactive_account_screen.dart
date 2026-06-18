import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class InactiveAccountScreen extends StatefulWidget {
  const InactiveAccountScreen({super.key});

  @override
  State<InactiveAccountScreen> createState() => _InactiveAccountScreenState();
}

class _InactiveAccountScreenState extends State<InactiveAccountScreen> {
  bool keepDataChecked = false;
  bool deleteAllChecked = false;
  String? deactivateReason;
  String? deactivateConfirm;

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
        title: Text(AppString.inactiveAccount.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppString.deactivateWarning.tr,
                        style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.red[800], height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCheckboxOption(AppString.keepMyData.tr, keepDataChecked, (val) {
                setState(() => keepDataChecked = val ?? false);
              }),
              _buildCheckboxOption(AppString.deleteAllMyActivity.tr, deleteAllChecked, (val) {
                setState(() => deleteAllChecked = val ?? false);
              }),
              const SizedBox(height: 24),
              Text(AppString.reasonForDeactivation.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.searchBarBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.fieldBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: deactivateReason,
                    hint: Text("I need a break", style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87)),
                    items: <String>['I need a break', 'Privacy concerns', 'Too many notifications', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => deactivateReason = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(AppString.areYouSureDeactivate.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const SizedBox(height: 12),
              _buildRadioOption("Yes, deactivate my account", "yes"),
              _buildRadioOption("Cancel", "no"),
              const SizedBox(height: 16),
              Text(
                AppString.reactivateNote.tr,
                style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _showConfirmDialog(context),
                  child: Text(
                    AppString.deactivateAccountButton.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Radio<String>(
              value: value,
              groupValue: deactivateConfirm,
              onChanged: (val) {
                setState(() => deactivateConfirm = val);
              },
              activeColor: AppTheme.primaryDeepBlue,
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          title: Text("Are you sure you want to delete your account?", style: AppFonts.titleStyle.copyWith(fontSize: 16), textAlign: TextAlign.center),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppTheme.textGrey400),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(AppString.cancel.tr, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => Get.back(), 
                    child: Text(AppString.delete.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
