import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Utilities/helper.dart';
import '../../Controller/auth_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedGender = '';
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final AuthController authController = Get.put(AuthController());

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(
            AppString.setYourProfile.tr,
            style: AppFonts.titleStyle.copyWith(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                AppString.enterYourFullName.tr,
                style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: nameController,
                hintText: 'Enter your name',
                prefix: Icon(Icons.person_outline, color: AppTheme.textGrey400),
                useBorder: true,
                borderColor: AppTheme.fieldBorderColor,
                borderRadius: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                AppString.enterYourEmailAddress.tr,
                style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: emailController,
                hintText: 'Enter your email',
                prefix: Icon(Icons.email_outlined, color: AppTheme.textGrey400),
                useBorder: true,
                borderColor: AppTheme.fieldBorderColor,
                borderRadius: 10,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                AppString.selectYourGender.tr,
                style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _genderOption('Female', Icons.female, Colors.pink)),
                  const SizedBox(width: 12),
                  Expanded(child: _genderOption('Male', Icons.male, Colors.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: _genderOption('Other', Icons.transgender, Colors.grey)),
                ],
              ),
              const SizedBox(height: 40),
              CustomButton(
                height: 50,
                width: double.infinity,
                title: AppString.continueText.tr,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    if (_imageFile == null) {
                      showSnackBar("Please select a profile image", false);
                      return;
                    }
                    if (selectedGender.isEmpty) {
                     showSnackBar("Please select your gender", false);
                      return;
                    }
                    authController.registerDonor(
                      context: context,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      gender: selectedGender,
                      profilePhoto: _imageFile,
                    );
                  }
                },
                color: AppTheme.primaryDeepBlue,
                borderRadius: BorderRadius.circular(10),
                showCenter: true,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: AppString.byContinuingText.tr,
                    style: AppFonts.verySmallText.copyWith(color: AppTheme.textGrey500),
                    children: [
                      TextSpan(
                        text: AppString.termsOfService.tr,
                        style: AppFonts.verySmallText.copyWith(color: AppTheme.primaryDeepBlue),
                      ),
                      TextSpan(text: AppString.and.tr),
                      TextSpan(
                        text: AppString.privacyPolicy.tr,
                        style: AppFonts.verySmallText.copyWith(color: AppTheme.primaryDeepBlue),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _genderOption(String title, IconData icon, Color activeIconColor) {
    bool isSelected = selectedGender == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? activeIconColor : AppTheme.textGrey400),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppFonts.smallText.copyWith(
                color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.textGrey500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
