import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/custom_appbar.dart';
import '../../Utilities/helper.dart';
import '../../Controller/auth_controller.dart';

class NgoDocumentsVerificationScreen extends StatefulWidget {
  const NgoDocumentsVerificationScreen({super.key});

  @override
  State<NgoDocumentsVerificationScreen> createState() => _NgoDocumentsVerificationScreenState();
}

class _NgoDocumentsVerificationScreenState extends State<NgoDocumentsVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController panController = TextEditingController();
  final TextEditingController tanController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController _12aController = TextEditingController();
  final TextEditingController _80gController = TextEditingController();
  
  final TextEditingController darpanController = TextEditingController();
  final TextEditingController csr1Controller = TextEditingController();
  final TextEditingController fcraController = TextEditingController();
  final TextEditingController otherRegController = TextEditingController();

  File? _panImage;
  File? _tanImage;
  File? _gstImage;
  File? _12aImage;
  File? _80gImage;
  File? _darpanImage;
  File? _csr1Image;
  File? _fcraImage;
  File? _otherRegImage;

  String? _panImageUrl;
  String? _tanImageUrl;
  String? _gstImageUrl;
  String? _12aImageUrl;
  String? _80gImageUrl;
  String? _darpanImageUrl;
  String? _csr1ImageUrl;
  String? _fcraImageUrl;
  String? _otherRegImageUrl;

  bool hasDarpan = true;
  bool hasCsr1 = false;
  bool hasFcra = false;
  bool hasOther = false;

  Future<void> _pickImage(Function(File) onImageSelected, Function(String?) onUrlReceived) async {
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
        onImageSelected(selectedFile);
        onUrlReceived(null);
      });

      print("Uploading selected document to get URL...");
      final AuthController authController = Get.put(AuthController());
      authController.uploadFile(selectedFile).then((url) {
        if (url != null) {
          print("Selected document URL is: $url");
          setState(() {
            onUrlReceived(url);
          });
        } else {
          print("Failed to upload selected document.");
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
        appBar: CustomAppBar(titleText: AppString.documentsVerification.tr),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // PAN Card
                _buildDocumentSection(
                  title: AppString.panCardNumber.tr,
                  hintText: AppString.enterPanCardNumber.tr,
                  controller: panController,
                  uploadTitle: AppString.uploadPanCardImage.tr,
                  file: _panImage,
                  onPickFile: () => _pickImage((file) => _panImage = file, (url) => _panImageUrl = url),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // TAN Card
                _buildDocumentSection(
                  title: AppString.tanCardNumber.tr,
                  hintText: AppString.enterTanCardNumber.tr,
                  controller: tanController,
                  uploadTitle: AppString.uploadTanCardImage.tr,
                  file: _tanImage,
                  onPickFile: () => _pickImage((file) => _tanImage = file, (url) => _tanImageUrl = url),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // GST Number
                _buildDocumentSection(
                  title: AppString.gstNumber.tr,
                  hintText: AppString.enterGstNumber.tr,
                  controller: gstController,
                  uploadTitle: AppString.uploadGstDocument.tr,
                  file: _gstImage,
                  onPickFile: () => _pickImage((file) => _gstImage = file, (url) => _gstImageUrl = url),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // 12A Registration
                _buildDocumentSection(
                  title: AppString.twelveARegistrationNumber.tr,
                  hintText: AppString.enter12ARegistrationNumber.tr,
                  controller: _12aController,
                  uploadTitle: AppString.upload12ACertificate.tr,
                  file: _12aImage,
                  onPickFile: () => _pickImage((file) => _12aImage = file, (url) => _12aImageUrl = url),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // 80G Registration
                _buildDocumentSection(
                  title: AppString.eightyGRegistrationNumber.tr,
                  hintText: AppString.enter80GRegistrationNumber.tr,
                  controller: _80gController,
                  uploadTitle: AppString.upload80GCertificate.tr,
                  file: _80gImage,
                  onPickFile: () => _pickImage((file) => _80gImage = file, (url) => _80gImageUrl = url),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                // Toggles
                _buildToggleSection(
                  title: AppString.darpanRegistration.tr,
                  value: hasDarpan,
                  onChanged: (val) => setState(() => hasDarpan = val),
                ),
                if (hasDarpan)
                  _buildDocumentSection(
                    title: AppString.registrationNumber.tr,
                    hintText: AppString.enterRegistrationNumber.tr,
                    controller: darpanController,
                    uploadTitle: AppString.uploadCertificate.tr,
                    file: _darpanImage,
                    onPickFile: () => _pickImage((file) => _darpanImage = file, (url) => _darpanImageUrl = url),
                    topPadding: false,
                  ),

                 _buildToggleSection(
                  title: AppString.csr1Registration.tr,
                  value: hasCsr1,
                  onChanged: (val) => setState(() => hasCsr1 = val),
                ),
                if (hasCsr1)
                  _buildDocumentSection(
                    title: "CSR 1 Registration Number",
                    hintText: "Enter CSR 1 Registration Number",
                    controller: csr1Controller,
                    uploadTitle: AppString.uploadCertificate.tr,
                    file: _csr1Image,
                    onPickFile: () => _pickImage((file) => _csr1Image = file, (url) => _csr1ImageUrl = url),
                    topPadding: false,
                  ),

                _buildToggleSection(
                  title: AppString.fcraRegistration.tr,
                  value: hasFcra,
                  onChanged: (val) => setState(() => hasFcra = val),
                ),
                if (hasFcra)
                  _buildDocumentSection(
                    title: "FCRA Registration Number",
                    hintText: "Enter FCRA Registration Number",
                    controller: fcraController,
                    uploadTitle: AppString.uploadCertificate.tr,
                    file: _fcraImage,
                    onPickFile: () => _pickImage((file) => _fcraImage = file, (url) => _fcraImageUrl = url),
                    topPadding: false,
                  ),

                _buildToggleSection(
                  title: AppString.anyOtherRegistration.tr,
                  value: hasOther,
                  onChanged: (val) => setState(() => hasOther = val),
                ),
                if (hasOther)
                  _buildDocumentSection(
                    title: AppString.nameOfRegistration.tr,
                    hintText: AppString.enterRegistrationName.tr,
                    controller: otherRegController,
                    uploadTitle: AppString.uploadCertificate.tr,
                    file: _otherRegImage,
                    onPickFile: () => _pickImage((file) => _otherRegImage = file, (url) => _otherRegImageUrl = url),
                    topPadding: false,
                  ),

                const SizedBox(height: 32),
                CustomButton(
                  height: 50,
                  width: double.infinity,
                  title: AppString.continueText.tr,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      // Validate mandatory files
                      if (_panImage == null) {
                        showSnackBar("Please upload PAN card image", false);
                        return;
                      }
                      if (_tanImage == null) {
                        showSnackBar("Please upload TAN card image", false);
                        return;
                      }
                      if (_gstImage == null) {
                        showSnackBar("Please upload GST document", false);
                        return;
                      }
                      if (_12aImage == null) {
                        showSnackBar("Please upload 12A certificate", false);
                        return;
                      }
                      if (_80gImage == null) {
                        showSnackBar("Please upload 80G certificate", false);
                        return;
                      }

                      // Validate conditional files
                      if (hasDarpan) {
                        if (darpanController.text.trim().isEmpty) {
                          showSnackBar("Please enter Darpan registration number", false);
                          return;
                        }
                        if (_darpanImage == null) {
                          showSnackBar("Please upload Darpan certificate", false);
                          return;
                        }
                      }
                      if (hasCsr1) {
                        if (csr1Controller.text.trim().isEmpty) {
                          showSnackBar("Please enter CSR 1 registration number", false);
                          return;
                        }
                        if (_csr1Image == null) {
                          showSnackBar("Please upload CSR 1 certificate", false);
                          return;
                        }
                      }
                      if (hasFcra) {
                        if (fcraController.text.trim().isEmpty) {
                          showSnackBar("Please enter FCRA registration number", false);
                          return;
                        }
                        if (_fcraImage == null) {
                          showSnackBar("Please upload FCRA certificate", false);
                          return;
                        }
                      }
                      if (hasOther) {
                        if (otherRegController.text.trim().isEmpty) {
                          showSnackBar("Please enter name of registration", false);
                          return;
                        }
                        if (_otherRegImage == null) {
                          showSnackBar("Please upload registration certificate", false);
                          return;
                        }
                      }

                      final Map<String, dynamic> firstScreenData = Get.arguments ?? {};
                      Get.toNamed(
                        MyRouters.ngoBankDetailsScreen,
                        arguments: {
                          ...firstScreenData,
                          'panNumber': panController.text.trim(),
                          'tanNumber': tanController.text.trim(),
                          'gstNumber': gstController.text.trim(),
                          'registration12A': _12aController.text.trim(),
                          'registration80G': _80gController.text.trim(),
                          'hasDarpan': hasDarpan,
                          'darpanNumber': darpanController.text.trim(),
                          'hasCSR1': hasCsr1,
                          'csr1Number': csr1Controller.text.trim(),
                          'hasFCRA': hasFcra,
                          'fcraNumber': fcraController.text.trim(),
                          'hasOtherRegistration': hasOther,
                          'otherRegistrationName': otherRegController.text.trim(),
                          'panImage': _panImageUrl ?? _panImage,
                          'tanImage': _tanImageUrl ?? _tanImage,
                          'gstDocument': _gstImageUrl ?? _gstImage,
                          'certificate12A': _12aImageUrl ?? _12aImage,
                          'certificate80G': _80gImageUrl ?? _80gImage,
                          'darpanCertificate': _darpanImageUrl ?? _darpanImage,
                          'csr1Certificate': _csr1ImageUrl ?? _csr1Image,
                          'fcraCertificate': _fcraImageUrl ?? _fcraImage,
                          'otherRegistrationCertificate': _otherRegImageUrl ?? _otherRegImage,
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

  Widget _buildToggleSection({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500))),
          CupertinoSwitch(
            value: value,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required String uploadTitle,
    required File? file,
    required VoidCallback onPickFile,
    bool topPadding = true,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topPadding) const SizedBox(height: 24),
        Text(title, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
        const SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          hintText: hintText,
          useBorder: true,
          borderColor: AppTheme.fieldBorderColor,
          borderRadius: 10,
          validator: validator,
        ),
        const SizedBox(height: 16),
        Text(uploadTitle, style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
        const SizedBox(height: 8),
        _buildFileUploadBox(onPickFile, file),
        const SizedBox(height: 24),
      ],
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
              Icon(file != null ? Icons.check_circle : Icons.cloud_upload_outlined, color: file != null ? Colors.green : Colors.blue, size: 32),
              const SizedBox(height: 8),
              Text(file != null ? "File selected" : AppString.clickToUpload.tr, style: AppFonts.mediumText.copyWith(color: Colors.blue, fontSize: 13)),
              const SizedBox(height: 4),
              Text("PNG, JPG (Max : 5MB)", style: AppFonts.regularText.copyWith(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
