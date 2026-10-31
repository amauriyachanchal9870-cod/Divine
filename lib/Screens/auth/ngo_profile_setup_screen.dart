import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';

class OfficialDetail {
  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'name': nameController.text.trim(),
      'designation': designationController.text.trim(),
      'email': emailController.text.trim(),
      'pan': panController.text.trim(),
      'aadharId': aadharController.text.trim(),
      'linkedInUrl': linkedInController.text.trim(),
    };
  }

  void dispose() {
    nameController.dispose();
    designationController.dispose();
    emailController.dispose();
    panController.dispose();
    aadharController.dispose();
    linkedInController.dispose();
  }
}

class NgoProfileSetupScreen extends StatefulWidget {
  const NgoProfileSetupScreen({super.key});

  @override
  State<NgoProfileSetupScreen> createState() => _NgoProfileSetupScreenState();
}

class _NgoProfileSetupScreenState extends State<NgoProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Item 1: Registration Type
  String selectedRegisteredType = 'Yes - As a Trust';

  // Item 2: Legal Name
  final TextEditingController legalNameController = TextEditingController();

  // Item 3: Registered Address & Registration Certificate Document
  final TextEditingController addressController = TextEditingController();
  File? _addressCertificate;

  // Item 4: Logo of Organization
  File? _logoImage;

  // Item 5: MOA & AOA / Trust Deed / Society Bye-laws (multiple documents)
  final List<File> _moaAoaFiles = [];

  // Item 6: PAN & Document
  final TextEditingController panController = TextEditingController();
  File? _panDoc;

  // Item 7: TAN & Document
  final TextEditingController tanController = TextEditingController();
  File? _tanDoc;

  // Item 8 (Corporate): GST & Document
  final TextEditingController gstController = TextEditingController();
  File? _gstDoc;

  // Item 9: Brief Profile of your Organization
  final TextEditingController briefProfileController = TextEditingController();

  // Corporate Items 10 - 13
  List<OfficialDetail> officials = [];
  final TextEditingController fillerNameController = TextEditingController();
  final TextEditingController fillerDesignationController = TextEditingController();
  final TextEditingController fillerPhoneController = TextEditingController();
  final TextEditingController fillerEmailController = TextEditingController();
  final TextEditingController fillerPanController = TextEditingController();
  final TextEditingController fillerAadharController = TextEditingController();
  File? _authorityLetterImage;
  final TextEditingController websiteUrlController = TextEditingController();
  final TextEditingController csrObligationController = TextEditingController();

  late String role;
  bool isCorporate = false;

  final ImagePicker _picker = ImagePicker();

  final TextInputFormatter upperCaseFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) => TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    ),
  );

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args != null && args['role'] != null) ? args['role'].toString().toLowerCase() : 'ngo';
    isCorporate = (role == 'corporate');
    if (isCorporate) {
      selectedRegisteredType = 'Yes - As a Private Limited Company';
      officials.add(OfficialDetail());
    }

    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.fetchMasterSettings();
      _loadVerifiedMobile();
      _checkGoogleSignIn();
    });
  }

  bool isGoogleSignIn = false;
  String googleEmail = '';

  Future<void> _checkGoogleSignIn() async {
    bool isGoogle = false;
    String gEmail = '';
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['isGoogleSignIn'] == true) isGoogle = true;
      if (args['googleEmail'] != null && args['googleEmail'].toString().trim().isNotEmpty) {
        gEmail = args['googleEmail'].toString().trim();
      }
    }
    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    if (!isGoogle) {
      isGoogle = await authController.isGoogleUser();
    }
    if (gEmail.isEmpty && isGoogle) {
      gEmail = await authController.getGoogleEmail();
    }
    if (mounted) {
      setState(() {
        isGoogleSignIn = isGoogle;
        googleEmail = gEmail;
        if (isGoogle && gEmail.isNotEmpty) {
          fillerEmailController.text = gEmail;
        }
      });
    }
  }

  String _extractTenDigitPhone(String raw) {
    if (raw.trim().isEmpty) return '';
    if (raw.contains(' ')) {
      final candidate = raw.split(' ').last.replaceAll(RegExp(r'\D'), '');
      if (candidate.length == 10) {
        return candidate;
      }
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  Future<void> _loadVerifiedMobile() async {
    String verified = '';
    final args = Get.arguments;
    if (args != null && args is Map && args['phone'] != null && args['phone'].toString().trim().isNotEmpty) {
      verified = _extractTenDigitPhone(args['phone'].toString());
    }
    if (verified.isEmpty) {
      final AuthController authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());
      verified = await authController.getVerifiedPhone();
    }
    if (verified.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final p = prefs.getString('verifiedMobile') ?? prefs.getString('userPhone') ?? prefs.getString('phone');
        if (p != null && p.trim().isNotEmpty) {
          verified = _extractTenDigitPhone(p);
        }
      } catch (_) {}
    }
    if (verified.isEmpty && Get.isRegistered<ProfileController>()) {
      final p = Get.find<ProfileController>().profileData.value?.phone;
      if (p != null && p.trim().isNotEmpty) {
        verified = _extractTenDigitPhone(p);
      }
    }
    if (verified.isEmpty && Get.isRegistered<HomeController>()) {
      final p = Get.find<HomeController>().homeData.value?.user?.phone;
      if (p != null && p.trim().isNotEmpty) {
        verified = _extractTenDigitPhone(p);
      }
    }
    if (verified.isNotEmpty && mounted) {
      setState(() {
        fillerPhoneController.text = verified;
      });
    }
  }

  @override
  void dispose() {
    legalNameController.dispose();
    addressController.dispose();
    panController.dispose();
    tanController.dispose();
    gstController.dispose();
    briefProfileController.dispose();

    for (var o in officials) {
      o.dispose();
    }
    fillerNameController.dispose();
    fillerDesignationController.dispose();
    fillerPhoneController.dispose();
    fillerEmailController.dispose();
    fillerPanController.dispose();
    fillerAadharController.dispose();
    websiteUrlController.dispose();
    csrObligationController.dispose();

    super.dispose();
  }

  Future<void> _pickDocumentOrImage({
    required Function(File file) onFilePicked,
    bool imagesOnly = false,
  }) async {
    if (imagesOnly) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        onFilePicked(File(image.path));
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Pick Image from Gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (image != null) {
                    onFilePicked(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Pick PDF Document'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );
                  if (result != null && result.files.single.path != null) {
                    onFilePicked(File(result.files.single.path!));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMultipleDocuments(Function(List<File> files) onFilesPicked) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Pick Images from Gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
                  if (images.isNotEmpty) {
                    onFilesPicked(images.map((img) => File(img.path)).toList());
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Pick PDF Documents'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );
                  if (result != null) {
                    List<File> files = result.paths
                        .where((p) => p != null)
                        .map((p) => File(p!))
                        .toList();
                    if (files.isNotEmpty) {
                      onFilesPicked(files);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getRegistrationOptions() {
    if (isCorporate) {
      return [
        'Yes - As a Proprietorship',
        'Yes - As a LLP',
        'Yes - As a Private Limited Company',
        'Yes - As a Limited Company',
        'No',
      ];
    }
    return [
      'Yes - As a Trust',
      'Yes - As a Society',
      'Yes - As a Section 25 or Section 8 Company',
      'No',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final regOptions = _getRegistrationOptions();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          titleText: isCorporate ? 'Set Corporate Profile' : 'Set NGO Profile',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                if (!isCorporate) ...[
                  // ==========================================
                  // Logo of your Organization (Moved to top for NGO)
                  // ==========================================
                  Center(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Logo of your Organization',
                            style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _pickDocumentOrImage(
                            imagesOnly: true,
                            onFilePicked: (f) => setState(() => _logoImage = f),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.fieldBorderColor, width: 1.5),
                                  image: _logoImage != null
                                      ? DecorationImage(
                                          image: FileImage(_logoImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _logoImage == null
                                    ? Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryDeepBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (isCorporate) ...[
                  // ==========================================
                  // 4. Logo of your Organization
                  //    Upload Image
                  // ==========================================
                  Text(
                    'Logo of your Organization',
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickDocumentOrImage(
                        imagesOnly: true,
                        onFilePicked: (f) => setState(() => _logoImage = f),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.fieldBorderColor, width: 1.5),
                              image: _logoImage != null
                                  ? DecorationImage(
                                image: FileImage(_logoImage!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _logoImage == null
                                ? Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDeepBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ==========================================
                // Is your organization a registered Non-Profit?
                // ==========================================
                Text(
                  isCorporate
                      ? 'Is your organization a registered Company?'
                      : 'Is your organization a registered Non-Profit?',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...regOptions.map((opt) {
                  return _buildRadioOption(
                    title: opt,
                    value: opt,
                    groupValue: selectedRegisteredType,
                    onChanged: (val) {
                      if (val == 'No') {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Notice"),
                            content: const Text("Please sign up as an Individual"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Get.offAllNamed(MyRouters.roleSelectionScreen);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                      setState(() {
                        selectedRegisteredType = val;
                      });
                    },
                  );
                }),
                const SizedBox(height: 20),

                // ==========================================
                // Legal Name of your Organization
                // ==========================================
                Text(
                  'Legal Name of your Organization',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: legalNameController,
                  hintText: 'Enter Legal Name',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter legal name' : null,
                ),
                const SizedBox(height: 20),

                // ==========================================
                // Registered Address of your Organization
                // Upload Document (Registration Certificate)
                // ==========================================
                Text(
                  'Registered Address of your Organization',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: addressController,
                  hintText: 'Enter Registered Address',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  maxLines: 2,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter registered address' : null,
                ),
                const SizedBox(height: 8),
                Text(
                  isCorporate
                      ? 'Upload Document (Registration Certificate/ Certificate of Incorporation/ LLPIN)'
                      : 'Upload Document (Registration Certificate)',
                  style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                ),
                _buildFileUploadBox(
                  label: isCorporate ? 'Upload Registration Document' : 'Upload Registration Certificate',
                  file: _addressCertificate,
                  onTap: () => _pickDocumentOrImage(
                    onFilePicked: (f) => setState(() => _addressCertificate = f),
                  ),
                  onRemove: () => setState(() => _addressCertificate = null),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // MOA & AOA / Trust Deed / Society Bye-laws (NGO)
                // MOA & AOA / LLP Agreement/ Partnership Deed (Corporate)
                // ==========================================
                Text(
                  isCorporate
                      ? 'MOA & AOA / LLP Agreement/ Partnership Deed'
                      : 'MOA & AOA / Trust Deed / Society Bye-laws',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildMultiDocumentUploadBox(
                  label: 'Upload Documents',
                  files: _moaAoaFiles,
                  onAddTap: () => _pickMultipleDocuments((files) {
                    setState(() {
                      _moaAoaFiles.addAll(files);
                    });
                  }),
                  onRemoveTap: (index) {
                    setState(() {
                      _moaAoaFiles.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 20),

                // ==========================================
                // PAN
                // Upload Document
                // ==========================================
                Text(
                  'PAN',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: panController,
                  hintText: 'Enter Organization PAN',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    upperCaseFormatter,
                  ],
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter PAN number';
                    if (val.trim().length != 10) return 'PAN must be 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildFileUploadBox(
                  label: 'Upload PAN Document',
                  file: _panDoc,
                  onTap: () => _pickDocumentOrImage(
                    onFilePicked: (f) => setState(() => _panDoc = f),
                  ),
                  onRemove: () => setState(() => _panDoc = null),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // TAN
                // Upload Document
                // ==========================================
                Text(
                  'TAN',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: tanController,
                  hintText: 'Enter TAN Number',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    upperCaseFormatter,
                  ],
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter TAN number';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildFileUploadBox(
                  label: 'Upload TAN Document',
                  file: _tanDoc,
                  onTap: () => _pickDocumentOrImage(
                    onFilePicked: (f) => setState(() => _tanDoc = f),
                  ),
                  onRemove: () => setState(() => _tanDoc = null),
                ),
                const SizedBox(height: 20),

                // ==========================================
                // GST (Corporate Item 8)
                // ==========================================
                if (isCorporate) ...[
                  Text(
                    'GST',
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: gstController,
                    hintText: 'Enter GST Number',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      upperCaseFormatter,
                    ],
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 10,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter GST number';
                      if (val.trim().length != 15) return 'GST must be 15 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFileUploadBox(
                    label: 'Upload GST Document',
                    file: _gstDoc,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => _gstDoc = f),
                    ),
                    onRemove: () => setState(() => _gstDoc = null),
                  ),
                  const SizedBox(height: 20),
                ],

                // ==========================================
                // Brief Profile of your Organization
                // (i-text: Short description - approx. 150 words)
                // ==========================================
                Text(
                  'Brief Profile of your Organization',
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Short description - approx. 150 words)',
                  style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: briefProfileController,
                  hintText: 'Enter brief profile of your organization...',
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                  maxLines: 4,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter brief profile' : null,
                ),
                const SizedBox(height: 20),

                if (isCorporate) ...[
                  // ==========================================
                  // 10. Directors / Partners / Key Management:
                  // ==========================================
                  Text(
                    "Directors / Partners / Key Management:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   "(allow user to add multiple officials)",
                  //   style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  // ),
                  const SizedBox(height: 12),
                  ...List.generate(officials.length, (index) => _buildOfficialCard(index)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          officials.add(OfficialDetail());
                        });
                      },
                      icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryDeepBlue),
                      label: Text(
                        "Add Another Official",
                        style: AppFonts.mediumText.copyWith(color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ==========================================
                  // 11. Details of the person filling this form:
                  // ==========================================
                  Text(
                    "Details of the person filling this form:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: AppTheme.fieldBorderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // a) Name
                        Text("a) Name", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerNameController,
                          hintText: "Enter Name",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter name' : null,
                        ),
                        const SizedBox(height: 12),

                        // b) Designation/ Role in the Organization
                        Text("b) Designation/ Role in the Organization", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerDesignationController,
                          hintText: "Enter Designation / Role",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter designation' : null,
                        ),
                        const SizedBox(height: 12),

                        // c) Phone Number
                        Text("c) Phone Number", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerPhoneController,
                          readOnly: !isGoogleSignIn,
                          hintText: "Enter Phone Number",
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter phone number';
                            if (val.trim().length != 10) return 'Phone number must be 10 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // d) E-mail ID
                        Text("d) E-mail ID", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerEmailController,
                          readOnly: isGoogleSignIn,
                          hintText: "Enter E-mail ID",
                          keyboardType: TextInputType.emailAddress,
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter email';
                            if (!GetUtils.isEmail(val.trim())) return 'Please enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // e) PAN
                        Text("e) PAN", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerPanController,
                          hintText: "Enter PAN Number",
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            upperCaseFormatter,
                          ],
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter PAN number';
                            if (val.trim().length != 10) return 'PAN must be 10 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // f) Aadhar/ other officially accepted ID
                        Text("f) Aadhar/ other officially accepted ID", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: fillerAadharController,
                          hintText: "Enter Aadhar",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter ID number' : null,
                        ),
                        const SizedBox(height: 12),

                        // g) Authority to represent organization (i-text: Upload Board Resolution/ Authority Letter)
                        Text("g) Authority to represent organization", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 2),
                        Text("(Upload Board Resolution/ Authority Letter)", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
                        _buildFileUploadBox(
                          label: 'Upload Authority Letter / Board Resolution',
                          file: _authorityLetterImage,
                          onTap: () => _pickDocumentOrImage(
                            onFilePicked: (f) => setState(() => _authorityLetterImage = f),
                          ),
                          onRemove: () => setState(() => _authorityLetterImage = null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ==========================================
                  // 12. Website URL of your Organization (i-text: Copy/ Paste URL)
                  // ==========================================
                  Text(
                    "Website URL of your Organization",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: websiteUrlController,
                    hintText: "https://yourorganization.com",
                    keyboardType: TextInputType.url,
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 20),

                  // ==========================================
                  // 13. Last Financial Year’s CSR Obligation (Mention briefly in 100 words)
                  // ==========================================
                  Text(
                    "Last Financial Year’s CSR Obligation",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "(Mention briefly in 100 words)",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: csrObligationController,
                    hintText: "Mention briefly...",
                    maxLines: 3,
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 16),

                // Continue Button
                CustomButton(
                  height: 50,
                  width: double.infinity,
                  title: AppString.continueText.tr,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedRegisteredType == 'No') {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Notice"),
                            content: const Text("Please sign up as an Individual"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Get.offAllNamed(MyRouters.roleSelectionScreen);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      if (isCorporate) {
                        if (_addressCertificate == null) {
                          showSnackBar("Please upload Registration Document", false);
                          return;
                        }
                        if (_logoImage == null) {
                          showSnackBar("Please upload Logo of your Organization", false);
                          return;
                        }
                        if (_moaAoaFiles.isEmpty) {
                          showSnackBar("Please upload MOA & AOA / LLP Agreement / Partnership Deed", false);
                          return;
                        }
                        if (_panDoc == null) {
                          showSnackBar("Please upload PAN document", false);
                          return;
                        }
                        if (_tanDoc == null) {
                          showSnackBar("Please upload TAN document", false);
                          return;
                        }
                        if (_gstDoc == null) {
                          showSnackBar("Please upload GST document", false);
                          return;
                        }
                        if (officials.isEmpty) {
                          showSnackBar("Please add at least one Director / Partner / Official", false);
                          return;
                        }
                        if (_authorityLetterImage == null) {
                          showSnackBar("Please upload Authority Letter / Board Resolution", false);
                          return;
                        }

                        final emailToVerify = fillerEmailController.text.trim();
                        final AuthController authCtrl = Get.put(AuthController());
                        if (emailToVerify.isNotEmpty) {
                          bool isAvailable = await authCtrl.checkEmailAvailability(context, emailToVerify);
                          if (!isAvailable) {
                            return;
                          }
                        }

                        final List<Map<String, dynamic>> officialsList = officials.map((o) => o.toJson()).toList();

                        Get.toNamed(
                          MyRouters.ngoDocumentsVerificationScreen,
                          arguments: {
                            'role': role,
                            'isGoogleSignIn': isGoogleSignIn,
                            'googleEmail': isGoogleSignIn ? (googleEmail.isNotEmpty ? googleEmail : fillerEmailController.text.trim()) : null,
                            'organizationType': 'Corporate',
                            'isRegisteredNonProfit': selectedRegisteredType,
                            'legalName': legalNameController.text.trim(),
                            'organizationName': legalNameController.text.trim(),
                            'registeredAddress': addressController.text.trim(),
                            'registrationCertificate': _addressCertificate,
                            'addressCertificate': _addressCertificate,
                            'logo': _logoImage,
                            'profilePhoto': _logoImage,
                            'moaAoaDocuments': _moaAoaFiles,
                            'panNumber': panController.text.trim(),
                            'panDocument': _panDoc,
                            'tanNumber': tanController.text.trim(),
                            'tanDocument': _tanDoc,
                            'gstNumber': gstController.text.trim(),
                            'gstDocument': _gstDoc,
                            'briefProfile': briefProfileController.text.trim(),
                            'directorsKeyManagement': officialsList,
                            'formFiller': {
                              'name': fillerNameController.text.trim(),
                              'designationRole': fillerDesignationController.text.trim(),
                              'phone': fillerPhoneController.text.trim(),
                              'email': fillerEmailController.text.trim(),
                              'pan': fillerPanController.text.trim(),
                              'aadharId': fillerAadharController.text.trim(),
                              'authorityLetter': _authorityLetterImage,
                            },
                            'authorizedPerson': fillerNameController.text.trim(),
                            'phone': fillerPhoneController.text.trim(),
                            'email': fillerEmailController.text.trim(),
                            'designation': fillerDesignationController.text.trim(),
                            'authorityLetter': _authorityLetterImage,
                            'websiteUrl': websiteUrlController.text.trim(),
                            'csrObligation': csrObligationController.text.trim(),
                          },
                        );
                      } else {
                        // NGO flow validation & navigation
                        if (_addressCertificate == null) {
                          showSnackBar("Please upload Registration Certificate for registered address", false);
                          return;
                        }
                        if (_moaAoaFiles.isEmpty) {
                          showSnackBar("Please upload MOA & AOA / Trust Deed / Society Bye-laws", false);
                          return;
                        }
                        if (_panDoc == null) {
                          showSnackBar("Please upload PAN document", false);
                          return;
                        }
                        if (_tanDoc == null) {
                          showSnackBar("Please upload TAN document", false);
                          return;
                        }

                        Get.toNamed(
                          MyRouters.ngoDocumentsVerificationScreen,
                          arguments: {
                            'role': role,
                            'isGoogleSignIn': isGoogleSignIn,
                            'googleEmail': isGoogleSignIn ? (googleEmail.isNotEmpty ? googleEmail : null) : null,
                            'phone': (Get.arguments != null && Get.arguments is Map && Get.arguments['phone'] != null && Get.arguments['phone'].toString().trim().isNotEmpty)
                                ? Get.arguments['phone'].toString().trim()
                                : (fillerPhoneController.text.trim().isNotEmpty ? fillerPhoneController.text.trim() : null),
                            'organizationType': 'Non-Profit',
                            'isRegisteredNonProfit': selectedRegisteredType,
                            'legalName': legalNameController.text.trim(),
                            'organizationName': legalNameController.text.trim(),
                            'registeredAddress': addressController.text.trim(),
                            'registrationCertificate': _addressCertificate,
                            'addressCertificate': _addressCertificate,
                            'logo': _logoImage,
                            'profilePhoto': _logoImage,
                            'moaAoaDocuments': _moaAoaFiles,
                            'panNumber': panController.text.trim(),
                            'panDocument': _panDoc,
                            'tanNumber': tanController.text.trim(),
                            'tanDocument': _tanDoc,
                            'briefProfile': briefProfileController.text.trim(),
                          },
                        );
                      }
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

  Widget _buildOfficialCard(int index) {
    final off = officials[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Official ${index + 1}",
                style: AppFonts.mediumText.copyWith(fontSize: 14, color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
              ),
              if (officials.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      officials.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),

          // a) Name
          Text("a) Name", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: off.nameController,
            hintText: "Enter Name",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter name' : null,
          ),
          const SizedBox(height: 12),

          // b) Designation
          Text("b) Designation", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: off.designationController,
            hintText: "Enter Designation",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter designation' : null,
          ),
          const SizedBox(height: 12),

          // c) E-mail ID
          Text("c) E-mail ID", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: off.emailController,
            hintText: "Enter E-mail ID",
            keyboardType: TextInputType.emailAddress,
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter email';
              if (!GetUtils.isEmail(val.trim())) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // d) PAN
          Text("d) PAN", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: off.panController,
            hintText: "Enter PAN",
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              upperCaseFormatter,
            ],
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter PAN';
              if (val.trim().length != 10) return 'PAN must be 10 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // e) Aadhar/ other officially accepted ID
          Text("e) Aadhar/ other officially accepted ID", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: off.aadharController,
            hintText: "Enter Aadhar",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter ID number' : null,
          ),
          const SizedBox(height: 12),

          // f) LinkedIn/ Other Official Profile (Copy/ Paste URL)
          Text("f) LinkedIn/ Other Official Profile", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),

          const SizedBox(height: 4),
          CommonTextField(
            controller: off.linkedInController,
            hintText: "https://linkedin.com/in/...",
            keyboardType: TextInputType.url,
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDeepBlue.withValues(alpha: 0.04) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryDeepBlue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryDeepBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppFonts.regularText.copyWith(
                  fontSize: 13,
                  color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadBox({
    required String label,
    required VoidCallback onTap,
    File? file,
    VoidCallback? onRemove,
  }) {
    bool hasFile = file != null;
    String fileName = hasFile ? file.path.split('/').last : '';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: onTap,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: hasFile ? Colors.green : AppTheme.fieldBorderColor,
            strokeWidth: 1.2,
            dashPattern: const <double>[6, 3],
            radius: const Radius.circular(10),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasFile ? Colors.green.withValues(alpha: 0.04) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? Colors.green : AppTheme.primaryDeepBlue,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? fileName : label,
                        style: AppFonts.mediumText.copyWith(
                          fontSize: 13,
                          color: hasFile ? Colors.green.shade800 : AppTheme.primaryDeepBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFile ? "File selected • Tap to change" : "(PDF, JPG, PNG)",
                        style: AppFonts.regularText.copyWith(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (hasFile && onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiDocumentUploadBox({
    required String label,
    required List<File> files,
    required VoidCallback onAddTap,
    required Function(int) onRemoveTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isNotEmpty)
          ...List.generate(files.length, (index) {
            final f = files[index];
            final name = f.path.split('/').last;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.04),
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: Colors.green, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: AppFonts.mediumText.copyWith(fontSize: 12, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => onRemoveTap(index),
                  ),
                ],
              ),
            );
          }),
        GestureDetector(
          onTap: onAddTap,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              color: AppTheme.fieldBorderColor,
              strokeWidth: 1.2,
              dashPattern: const <double>[6, 3],
              radius: const Radius.circular(10),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.primaryDeepBlue, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      files.isEmpty ? label : "Add Another Document",
                      style: AppFonts.mediumText.copyWith(
                        fontSize: 13,
                        color: AppTheme.primaryDeepBlue,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
