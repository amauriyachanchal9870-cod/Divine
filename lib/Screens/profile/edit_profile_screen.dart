import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _orgNameController;
  late TextEditingController _addressController;
  late TextEditingController _yearsController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _aboutController;

  String _countryCode = "+91";
  String _selectedGender = "Male";

  @override
  void initState() {
    super.initState();
    final ProfileController profileController = Get.put(ProfileController());
    final p = profileController.profileData.value;

    _nameController = TextEditingController(text: p?.name ?? "");
    _orgNameController = TextEditingController(text: p?.organizationName ?? "Green Earth Foundation");
    _addressController = TextEditingController(text: p?.registeredAddress ?? "405, Meghmalhar CHS, CRYSTAL ARMUS, Narayan, Mumbai");
    _yearsController = TextEditingController(text: p?.impactStats ?? "100");
    _emailController = TextEditingController(text: p?.email ?? "admin@gmail.com");
    _aboutController = TextEditingController(
      text: (p?.impactStats != null && p!.impactStats!.isNotEmpty) ? p.impactStats : "Since our founding over 100 years ago, we have changed the lives of over 1 billion children. We believe every child deserves a future. In more than 120 countries, we work every day to give children a healthy start in life."
    );

    String phoneVal = p?.phone ?? "";
    if (phoneVal.startsWith("+")) {
      final parts = phoneVal.split(" ");
      if (parts.length > 1) {
        _countryCode = parts[0];
        _phoneController = TextEditingController(text: parts.sublist(1).join(" "));
      } else {
        if (phoneVal.startsWith("+91")) {
          _countryCode = "+91";
          _phoneController = TextEditingController(text: phoneVal.substring(3).trim());
        } else {
          _phoneController = TextEditingController(text: phoneVal);
        }
      }
    } else {
      _phoneController = TextEditingController(text: phoneVal.isEmpty ? "7643547698" : phoneVal);
    }

    if (p?.gender != null && p!.gender!.isNotEmpty) {
      _selectedGender = p.gender!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgNameController.dispose();
    _addressController.dispose();
    _yearsController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _showEditPhoneBottomSheet(BuildContext context) {
    final TextEditingController bottomPhoneController = TextEditingController(text: _phoneController.text);
    String bottomCountryCode = _countryCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyDividerE0,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppString.editPhoneNumberLabel.tr,
                style: AppFonts.titleStyle.copyWith(fontSize: 20, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                AppString.verificationSentNotice.tr,
                style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.fieldBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: bottomCountryCode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      items: <String>['+91', '+1', '+44', '+971'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: AppFonts.mediumText.copyWith(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          bottomCountryCode = newValue;
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 24, color: AppTheme.fieldBorderColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: bottomPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "000-000-0000",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (bottomPhoneController.text.trim().isEmpty) {
                      Get.snackbar(
                        AppString.phoneNotEmptyError.tr, 
                        AppString.phoneNotEmptyError.tr, 
                        backgroundColor: AppTheme.redColor, 
                        colorText: AppTheme.whiteColor
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _showOtpBottomSheet(context, bottomCountryCode, bottomPhoneController.text);
                  },
                  child: Text(
                    AppString.continueText.tr,
                    style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtpBottomSheet(BuildContext context, String code, String number) {
    final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

    otpControllers[0].text = "2";
    otpControllers[1].text = "6";
    otpControllers[2].text = "0";
    otpControllers[3].text = "0";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyDividerE0,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppString.enterVerificationCode.tr,
                style: AppFonts.titleStyle.copyWith(fontSize: 20, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                AppString.verificationCodeSentNotice.tr,
                style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.fieldBorderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppFonts.semiBoldText.copyWith(fontSize: 18, color: Colors.black87),
                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${AppString.didntReceiveOtpResend.tr.split('?').first}? ",
                    style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar(AppString.otpSent.tr, AppString.otpSentSuccess.tr);
                    },
                    child: Text(
                      AppString.resend.tr,
                      style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    AppString.pleaseDoNotShareCode.tr,
                    style: AppFonts.regularText.copyWith(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    String otp = otpControllers.map((c) => c.text).join();
                    if (otp.length < 4) {
                      Get.snackbar(
                        AppString.enterValid4DigitCode.tr, 
                        AppString.enterValid4DigitCode.tr, 
                        backgroundColor: AppTheme.redColor, 
                        colorText: AppTheme.whiteColor
                      );
                      return;
                    }
                    setState(() {
                      _phoneController.text = number;
                      _countryCode = code;
                    });
                    Navigator.pop(context);
                    Get.snackbar(
                      AppString.success.tr, 
                      AppString.verificationSuccessful.tr, 
                      backgroundColor: AppTheme.greenColor, 
                      colorText: AppTheme.whiteColor
                    );
                  },
                  child: Text(
                    AppString.continueText.tr,
                    style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    final isDonor = profileController.profileData.value?.role == "donor";

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(
            AppString.editProfile.tr,
            style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Edit section
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        final p = profileController.profileData.value;
                        final profilePhoto = p?.profilePhoto ?? p?.logo ?? '';
                        return Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.greyBg100,
                            border: Border.all(color: AppTheme.fieldBorderColor, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: profilePhoto.isNotEmpty
                                ? NetworkImage(profilePhoto) as ImageProvider
                                : const AssetImage('assets/images/ngo_logo.png'),
                          ),
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.whiteColor,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                if (isDonor) ...[
                  // ---------------- DONOR LAYOUT (First Screen) ----------------
                  Text(
                    AppString.personalDetails.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: "Full Name",
                    controller: _nameController,
                    hint: "Enter Your Full Name",
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: "Email Address",
                    controller: _emailController,
                    hint: "Enter Your Email Address",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Enter Your Phone Number",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showEditPhoneBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.fieldBorderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _countryCode,
                            style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 20, color: AppTheme.fieldBorderColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _phoneController.text,
                              style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Select Your Gender",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton(
                          label: "Female",
                          icon: Icons.female,
                          isSelected: _selectedGender == "Female",
                          onTap: () => setState(() => _selectedGender = "Female"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderButton(
                          label: "Male",
                          icon: Icons.male,
                          isSelected: _selectedGender == "Male",
                          onTap: () => setState(() => _selectedGender = "Male"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderButton(
                          label: "Other",
                          isSelected: _selectedGender == "Other",
                          onTap: () => setState(() => _selectedGender = "Other"),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // ---------------- NGO LAYOUT (Second Screen) ----------------
                  Text(
                    AppString.personalDetails.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: AppString.organizationName.tr,
                    controller: _orgNameController,
                    hint: AppString.enterOrganizationName.tr,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: AppString.registeredAddress.tr,
                    controller: _addressController,
                    hint: AppString.enterFullOfficialAddress.tr,
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: AppString.years.tr,
                    controller: _yearsController,
                    hint: AppString.years.tr,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    AppString.enterYourPhoneNo.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showEditPhoneBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.fieldBorderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _countryCode,
                            style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black87),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 20, color: AppTheme.fieldBorderColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _phoneController.text,
                              style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: AppString.enterYourEmailAddress.tr,
                    controller: _emailController,
                    hint: AppString.enterYourEmailAddress.tr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),

                  Text(
                    AppString.ourMission.tr,
                    style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    label: AppString.aboutUs.tr,
                    controller: _aboutController,
                    hint: AppString.writeHere.tr,
                    maxLines: 5,
                  ),
                ],
                const SizedBox(height: 40),

                // Save Changes button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Get.back();
                        Get.snackbar(
                          AppString.success.tr, 
                          AppString.profileUpdatedSuccessfully.tr, 
                          backgroundColor: AppTheme.greenColor, 
                          colorText: AppTheme.whiteColor
                        );
                      }
                    },
                    child: Text(
                      AppString.saveChanges.tr,
                      style: AppFonts.semiBoldText.copyWith(color: AppTheme.whiteColor, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color iconColor = Colors.grey;
    if (label == "Female") iconColor = Colors.purple;
    if (label == "Male") iconColor = Colors.teal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F4F8) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppFonts.semiBoldText.copyWith(
                fontSize: 14,
                color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.fieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.fieldBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryDeepBlue),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppString.fieldRequiredError.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}
