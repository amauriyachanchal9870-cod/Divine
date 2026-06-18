import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Utilities/custom_appbar.dart';
import '../../Controller/auth_controller.dart';

class NgoBankDetailsScreen extends StatefulWidget {
  const NgoBankDetailsScreen({super.key});

  @override
  State<NgoBankDetailsScreen> createState() => _NgoBankDetailsScreenState();
}

class _NgoBankDetailsScreenState extends State<NgoBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchAddressController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(titleText: 'Bank Details'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Account Holder Name
                Text('Account Holder Name', style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: accountHolderController,
                  hintText: 'Enter Full Name',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Bank Name
                Text('Bank Name', style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: bankNameController,
                  hintText: 'Enter Bank Name',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Branch Address
                Text('Branch Address', style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: branchAddressController,
                  hintText: 'Enter Branch Address',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Account Number
                Text('Account Number', style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: accountNumberController,
                  hintText: 'Enter Account Number',
                  keyboardType: TextInputType.number,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // IFSC Code
                Text('IFSC Code', style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: ifscCodeController,
                  hintText: 'Enter IFSC Code',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 40),

                CustomButton(
                  height: 50,
                  width: double.infinity,
                  title: AppString.continueText.tr,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      final AuthController authController = Get.put(AuthController());
                      final Map<String, dynamic> combinedData = Get.arguments ?? {};
                      
                      authController.registerNgo(
                        context: context,
                        ngoData: combinedData,
                        bankAccountHolder: accountHolderController.text.trim(),
                        bankName: bankNameController.text.trim(),
                        bankBranch: branchAddressController.text.trim(),
                        bankAccountNumber: accountNumberController.text.trim(),
                        bankIFSC: ifscCodeController.text.trim(),
                      );
                    }
                  },
                  color: AppTheme.primaryDeepBlue,
                  borderRadius: BorderRadius.circular(10),
                  showCenter: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
