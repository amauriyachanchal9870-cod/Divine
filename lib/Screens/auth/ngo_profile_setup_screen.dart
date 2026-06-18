import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../Controller/auth_controller.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/custom_appbar.dart';
import '../../Utilities/helper.dart';

class NgoProfileSetupScreen extends StatefulWidget {
  const NgoProfileSetupScreen({super.key});

  @override
  State<NgoProfileSetupScreen> createState() => _NgoProfileSetupScreenState();
}

class _NgoProfileSetupScreenState extends State<NgoProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController authPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  String selectedDesignation = 'Select Designation';
  String selectedGender = '';
  File? _profileImage;
  File? _addressCertificate;
  String? _profileImageUrl;
  String? _addressCertificateUrl;

  Future<void> _pickImage(bool isProfile) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null) {
      final selectedFile = File(image.path);
      setState(() {
        if (isProfile) {
          _profileImage = selectedFile;
          _profileImageUrl = null;
        } else {
          _addressCertificate = selectedFile;
          _addressCertificateUrl = null;
        }
      });

      // Upload and print the image URL at the select time
      print("Uploading selected image to get URL...");
      final AuthController authController = Get.put(AuthController());
      authController.uploadFile(selectedFile).then((url) {
        if (url != null) {
          print("Selected image URL is: $url");
          setState(() {
            if (isProfile) {
              _profileImageUrl = url;
            } else {
              _addressCertificateUrl = url;
            }
          });
        } else {
          print("Failed to upload selected image.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(titleText: 'Set Your Profile'),
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
                    onTap: () => _pickImage(true),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImage == null
                              ? Icon(Icons.business, size: 50, color: Colors.grey.shade400)
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
                
                // Organization Name
                Text(AppString.organizationName.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: orgNameController,
                  hintText: AppString.enterOrganizationName.tr,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                // Registered Address
                Text(AppString.registeredAddress.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: addressController,
                  hintText: AppString.enterFullOfficialAddress.tr,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                // Upload Registered Address Certificate
                Text(AppString.uploadRegisteredAddressCertificate.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                _buildFileUploadBox(() => _pickImage(false), _addressCertificate),
                const SizedBox(height: 24),

                // Name of Authorized Person
                Text(AppString.nameOfAuthorizedPerson.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: authPersonController,
                  hintText: AppString.enterFullName.tr,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Phone Number
                // Text(AppString.enterPhoneNo.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: phoneController,
                  hintText: "000-000-0000",
                  keyboardType: TextInputType.phone,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Email Address
                Text(AppString.enterYourEmailAddress.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: emailController,
                  hintText: AppString.enterYourEmailAddress.tr,
                  keyboardType: TextInputType.emailAddress,
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Designation
                Text(AppString.designation.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.fieldBorderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDesignation,
                      items: <String>[
                        'Select Designation',
                        'Director',
                        'Founder',
                        'Co - Founder',
                        'Chairperson',
                        'Vice - Chairperson',
                        'President',
                        'Vice - President',
                        'Member',
                        'Secretary',
                        'Project Manager',
                        'Co - ordinator',
                        'Chief Executive Officer (CEO)',
                        'Company Secretary (CS)',
                        'Chief Financial Officer (CFO)',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: AppFonts.regularText.copyWith(color: value == 'Select Designation' ? Colors.grey : Colors.black)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDesignation = val!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Gender
                Text(AppString.selectYourGender.tr, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _genderOption('Female', Icons.female, Colors.pink)),
                    const SizedBox(width: 8),
                    Expanded(child: _genderOption('Male', Icons.male, Colors.teal)),
                    const SizedBox(width: 8),
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
                      if (_profileImage == null) {
                        showSnackBar("Please select a profile image", false);
                        return;
                      }
                      if (_addressCertificate == null) {
                        showSnackBar("Please upload registered address certificate", false);
                        return;
                      }
                      if (selectedDesignation == 'Select Designation' || selectedDesignation.isEmpty) {
                        showSnackBar("Please select designation", false);
                        return;
                      }
                      if (selectedGender.isEmpty) {
                        showSnackBar("Please select your gender", false);
                        return;
                      }
                      Get.toNamed(
                        MyRouters.ngoDocumentsVerificationScreen,
                        arguments: {
                          'organizationName': orgNameController.text.trim(),
                          'registeredAddress': addressController.text.trim(),
                          'authorizedPerson': authPersonController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'email': emailController.text.trim(),
                          'designation': selectedDesignation,
                          'gender': selectedGender,
                          'profilePhoto': _profileImageUrl ?? _profileImage,
                          'addressCertificate': _addressCertificateUrl ?? _addressCertificate,
                        },
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

  Widget _buildFileUploadBox(VoidCallback onTap, File? file) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        // color: AppTheme.fieldBorderColor,
        // strokeWidth: 1,
        // dashPattern: const <double>[6, 4],
        // borderType: BorderType.rRect,
        // radius: const Radius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(file != null ? Icons.check_circle : Icons.cloud_upload_outlined, color: file != null ? Colors.green : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(file != null ? "File selected" : AppString.clickToUpload.tr, style: AppFonts.mediumText.copyWith(color: AppTheme.primaryDeepBlue, fontSize: 13)),
              const SizedBox(height: 4),
              Text("PNG, JPG (Max : 5MB)", style: AppFonts.regularText.copyWith(color: Colors.grey, fontSize: 11)),
            ],
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
            Icon(icon, size: 16, color: isSelected ? activeIconColor : AppTheme.textGrey400),
            const SizedBox(width: 4),
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
