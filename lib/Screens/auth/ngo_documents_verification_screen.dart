import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

class NgoDocumentsVerificationScreen extends StatefulWidget {
  const NgoDocumentsVerificationScreen({super.key});

  @override
  State<NgoDocumentsVerificationScreen> createState() => _NgoDocumentsVerificationScreenState();
}

class _NgoDocumentsVerificationScreenState extends State<NgoDocumentsVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Item 9: Directors / Trustees / Key Management
  List<OfficialDetail> officials = [];

  // Item 10: Details of person filling form
  final TextEditingController fillerNameController = TextEditingController();
  final TextEditingController fillerDesignationController = TextEditingController();
  final TextEditingController fillerPhoneController = TextEditingController();
  final TextEditingController fillerEmailController = TextEditingController();
  final TextEditingController fillerPanController = TextEditingController();
  final TextEditingController fillerAadharController = TextEditingController();
  File? _authorityLetterImage;

  // Item 11: 12A Certification
  bool has12A = false;
  final TextEditingController cert12aController = TextEditingController();
  File? cert12aImage;

  // Item 12: 80G Certification
  bool has80G = false;
  final TextEditingController cert80gController = TextEditingController();
  File? cert80gImage;

  // Item 13: DARPAN Registration
  bool hasDarpan = false;
  final TextEditingController darpanController = TextEditingController();
  File? _darpanImage;

  // Item 14: CSR-1 Certification
  bool hasCsr1 = false;
  final TextEditingController csr1Controller = TextEditingController();
  File? _csr1Image;

  // Item 15: FCRA Certification
  bool hasFcra = false;
  final TextEditingController fcraController = TextEditingController();
  File? _fcraImage;

  // Item 16: Website URL
  final TextEditingController websiteUrlController = TextEditingController();

  // ==========================================
  // Corporate Flow Fields (Items 14 to 16)
  // ==========================================
  // Item 14: Amount Spent on CSR in Previous Financial Year:
  String selectedCsrAmountSpent = '0 - 1 Crore';

  // Item 15: What are your organization’s CSR focus areas? (Allow multiple selections)
  final Set<String> selectedCsrFocusAreas = {};
  final TextEditingController otherCsrFocusController = TextEditingController();
  final List<String> csrFocusAreaOptions = [
    'Education',
    'Healthcare',
    'Women Empowerment',
    'Child Welfare',
    'Senior Citizen Welfare',
    'Rural Development',
    'Skill Development',
    'Livelihood Development',
    'Environmental Sustainability',
    'Sanitation & Clean Water',
    'Disaster Management',
    'Animal Welfare',
    'Sports',
    'Art & Culture',
    'Slum Area Development',
    'Differently-Abled Persons',
    'Research & Development',
    'Armed Forces Veterans',
    'Farmers',
    'Students',
    'Hunger & Poverty',
    'Others, please specify',
  ];

  // Item 16: What are your organization’s funding preferences?
  String selectedFundingPreference = 'One-Time Funding';

  late Map<String, dynamic> firstScreenData;
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
    firstScreenData = Get.arguments ?? {};
    role = (firstScreenData['role'] ?? 'ngo').toString().toLowerCase();
    isCorporate = (role == 'corporate');

    // Add default 1 official
    officials.add(OfficialDetail());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVerifiedMobile();
      _checkGoogleSignIn();
    });
  }

  bool isGoogleSignIn = false;
  String googleEmail = '';

  Future<void> _checkGoogleSignIn() async {
    bool isGoogle = false;
    String gEmail = '';
    final args = firstScreenData;
    if (args['isGoogleSignIn'] == true) isGoogle = true;
    if (args['googleEmail'] != null && args['googleEmail'].toString().trim().isNotEmpty) {
      gEmail = args['googleEmail'].toString().trim();
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
    final args = firstScreenData;
    if (args['phone'] != null && args['phone'].toString().trim().isNotEmpty) {
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
    for (var o in officials) {
      o.dispose();
    }
    fillerNameController.dispose();
    fillerDesignationController.dispose();
    fillerPhoneController.dispose();
    fillerEmailController.dispose();
    fillerPanController.dispose();
    fillerAadharController.dispose();

    cert12aController.dispose();
    cert80gController.dispose();
    darpanController.dispose();
    csr1Controller.dispose();
    fcraController.dispose();
    websiteUrlController.dispose();
    otherCsrFocusController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          titleText: isCorporate ? 'Set Corporate Profile' : 'Documents Verification',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 12),
                // Text(
                //   "Step 2 of 3: Management & Certifications",
                //   style: AppFonts.mediumText.copyWith(
                //     color: AppTheme.primaryDeepBlue,
                //     fontSize: 13,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                const SizedBox(height: 20),

                if (isCorporate) ...[
                  // ==========================================
                  // CORPORATE FLOW (Items 14 to 16 from PDF)
                  // ==========================================

                  // 14. Amount Spent on CSR in Previous Financial Year:
                  Text(
                    "Amount Spent on CSR in Previous Financial Year:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 1 Crore', '1 Crore - 10 Crore', 'More than 10 Crore'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedCsrAmountSpent,
                      onChanged: (val) => setState(() => selectedCsrAmountSpent = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 15. What are your organization’s CSR focus areas? (Allow multiple selections)
                  Text(
                    "What are your organization’s CSR focus areas?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...csrFocusAreaOptions.map((area) {
                    final isSelected = selectedCsrFocusAreas.contains(area);
                    return _buildCheckboxOption(
                      area,
                      isSelected,
                      (val) {
                        setState(() {
                          if (val == true) {
                            selectedCsrFocusAreas.add(area);
                          } else {
                            selectedCsrFocusAreas.remove(area);
                          }
                        });
                      },
                    );
                  }),
                  if (selectedCsrFocusAreas.contains('Others, please specify')) ...[
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: otherCsrFocusController,
                      hintText: "Please specify other focus area",
                      useBorder: true,
                      borderColor: AppTheme.fieldBorderColor,
                      borderRadius: 8,
                      validator: (val) {
                        if (selectedCsrFocusAreas.contains('Others, please specify') && (val == null || val.trim().isEmpty)) {
                          return 'Please specify other focus area';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 16. What are your organization’s funding preferences?
                  Text(
                    "What are your organization’s funding preferences?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'One-Time Funding',
                    'Multi-Year Funding',
                    'Project-Based Funding',
                    'Programme-Based Funding',
                    'Infrastructure Support',
                  ].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedFundingPreference,
                      onChanged: (val) => setState(() => selectedFundingPreference = val),
                    );
                  }),
                ] else ...[
                  // ==========================================
                  // Directors / Trustees / Key Management (NGO)
                  // ==========================================
                  Text(
                    "Directors / Trustees / Key Management:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                ...List.generate(officials.length, (index) {
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
                          hintText: "Enter Email ID",
                          keyboardType: TextInputType.emailAddress,
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter email';
                            if (!val.contains('@') || !val.contains('.')) return 'Please enter valid email';
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
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  );
                }),

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
                const SizedBox(height: 24),

                // ==========================================
                // 10. Details of the person filling this form:
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
                        hintText: "Enter Email ID",
                        keyboardType: TextInputType.emailAddress,
                        useBorder: true,
                        borderColor: AppTheme.fieldBorderColor,
                        borderRadius: 8,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter email';
                          if (!val.contains('@') || !val.contains('.')) return 'Please enter valid email';
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
                          if (val == null || val.trim().isEmpty) return 'Please enter PAN';
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

                      // g) Authority to represent organization (Upload Board Resolution/ Authority Letter)
                      Text(
                        "g) Authority to represent organization",
                        style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                      ),
                      // const SizedBox(height: 2),
                      // Text(
                      //   "(Upload Board Resolution/ Authority Letter)",
                      //   style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                      // ),
                      _buildFileUploadBox(
                        label: 'Upload Board Resolution / Authority Letter',
                        file: _authorityLetterImage,
                        onTap: () => _pickDocumentOrImage(
                          onFilePicked: (f) => setState(() => _authorityLetterImage = f),
                        ),
                        onRemove: () => setState(() => _authorityLetterImage = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ==========================================
                // Certifications (NGO Flow Only)
                // ==========================================
                if (!isCorporate) ...[
                // ==========================================
                // 11. Does your Organization have 12A Certification?
                // ==========================================
                Text(
                  "Does your Organization have 12A Certification?",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildYesNoRadio(
                  value: has12A,
                  onChanged: (val) => setState(() => has12A = val),
                ),
                if (has12A) ...[
                  const SizedBox(height: 8),
                  Text("Upload 12A Certificate", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                  _buildFileUploadBox(
                    label: 'Upload 12A Certificate',
                    file: cert12aImage,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => cert12aImage = f),
                    ),
                    onRemove: () => setState(() => cert12aImage = null),
                  ),
                ],
                const SizedBox(height: 20),

                // ==========================================
                // 12. Does your Organization have 80G Certification?
                // ==========================================
                Text(
                  "Does your Organization have 80G Certification?",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildYesNoRadio(
                  value: has80G,
                  onChanged: (val) => setState(() => has80G = val),
                ),
                if (has80G) ...[
                  const SizedBox(height: 8),
                  Text("Upload 80G Certificate", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                  _buildFileUploadBox(
                    label: 'Upload 80G Certificate',
                    file: cert80gImage,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => cert80gImage = f),
                    ),
                    onRemove: () => setState(() => cert80gImage = null),
                  ),
                ],
                const SizedBox(height: 20),

                // ==========================================
                // 13. Does your Organization have DARPAN Registration?
                // ==========================================
                Text(
                  "Does your Organization have DARPAN Registration?",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildYesNoRadio(
                  value: hasDarpan,
                  onChanged: (val) => setState(() => hasDarpan = val),
                ),
                if (hasDarpan) ...[
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: darpanController,
                    hintText: "Enter DARPAN Registration Number",
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 8,
                    validator: hasDarpan
                        ? (val) => val == null || val.trim().isEmpty ? 'Please enter DARPAN registration number' : null
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text("Upload DARPAN Certificate", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                  _buildFileUploadBox(
                    label: 'Upload DARPAN Certificate',
                    file: _darpanImage,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => _darpanImage = f),
                    ),
                    onRemove: () => setState(() => _darpanImage = null),
                  ),
                ],
                const SizedBox(height: 20),

                // ==========================================
                // 14. Does your Organization have CSR-1 Certification?
                // ==========================================
                Text(
                  "Does your Organization have CSR-1 Certification?",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildYesNoRadio(
                  value: hasCsr1,
                  onChanged: (val) => setState(() => hasCsr1 = val),
                ),
                if (hasCsr1) ...[
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: csr1Controller,
                    hintText: "Enter CSR-1 Registration Number",
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 8,
                    validator: hasCsr1
                        ? (val) => val == null || val.trim().isEmpty ? 'Please enter CSR-1 registration number' : null
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text("Upload CSR-1 Certificate", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                  _buildFileUploadBox(
                    label: 'Upload CSR-1 Certificate',
                    file: _csr1Image,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => _csr1Image = f),
                    ),
                    onRemove: () => setState(() => _csr1Image = null),
                  ),
                ],
                const SizedBox(height: 20),

                // ==========================================
                // 15. Does your Organization have FCRA Certification?
                // ==========================================
                Text(
                  "Does your Organization have FCRA Certification?",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                _buildYesNoRadio(
                  value: hasFcra,
                  onChanged: (val) => setState(() => hasFcra = val),
                ),
                if (hasFcra) ...[
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: fcraController,
                    hintText: "Enter FCRA Registration Number",
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 8,
                    validator: hasFcra
                        ? (val) => val == null || val.trim().isEmpty ? 'Please enter FCRA registration number' : null
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text("Upload FCRA Certificate", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                  _buildFileUploadBox(
                    label: 'Upload FCRA Certificate',
                    file: _fcraImage,
                    onTap: () => _pickDocumentOrImage(
                      onFilePicked: (f) => setState(() => _fcraImage = f),
                    ),
                    onRemove: () => setState(() => _fcraImage = null),
                  ),
                ],
                const SizedBox(height: 20),
                ],

                // ==========================================
                // Website URL of your Organization
                // (i-text: Copy/ Paste URL)
                // ==========================================
                Text(
                  "Website URL of your Organization",
                  style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: websiteUrlController,
                  hintText: "https://yourorganization.org",
                  useBorder: true,
                  borderColor: AppTheme.fieldBorderColor,
                  borderRadius: 10,
                ),

                ],

                const SizedBox(height: 36),

                // Continue Button
                CustomButton(
                  height: 50,
                  width: double.infinity,
                  title: AppString.continueText.tr,
                  onTap: () async {
                    if (isCorporate) {
                      if (_formKey.currentState!.validate()) {
                        if (selectedCsrAmountSpent.trim().isEmpty) {
                          showSnackBar("Please select amount spent on CSR in previous financial year", false);
                          return;
                        }
                        if (selectedCsrFocusAreas.isEmpty) {
                          showSnackBar("Please select at least one CSR focus area", false);
                          return;
                        }
                        if (selectedCsrFocusAreas.contains('Others, please specify') &&
                            otherCsrFocusController.text.trim().isEmpty) {
                          showSnackBar("Please specify other focus area", false);
                          return;
                        }

                        Get.toNamed(
                          MyRouters.ngoBankDetailsScreen,
                          arguments: {
                            ...firstScreenData,
                            'csrAmountSpent': selectedCsrAmountSpent,
                            'csrFocusAreas': selectedCsrFocusAreas.toList(),
                            'otherCsrFocus': otherCsrFocusController.text.trim(),
                            'fundingPreference': selectedFundingPreference,
                          },
                        );
                      }
                    } else {
                      if (_formKey.currentState!.validate()) {
                        if (officials.isEmpty) {
                          showSnackBar("Please add at least one Director / Trustee / Official", false);
                          return;
                        }

                        if (_authorityLetterImage == null) {
                          showSnackBar("Please upload Authority Letter / Board Resolution", false);
                          return;
                        }

                        if (has12A && cert12aImage == null) {
                          showSnackBar("Please upload 12A Certificate", false);
                          return;
                        }
                        if (has80G && cert80gImage == null) {
                          showSnackBar("Please upload 80G Certificate", false);
                          return;
                        }
                        if (hasDarpan) {
                          if (darpanController.text.trim().isEmpty) {
                            showSnackBar("Please enter DARPAN registration number", false);
                            return;
                          }
                          if (_darpanImage == null) {
                            showSnackBar("Please upload DARPAN Certificate", false);
                            return;
                          }
                        }
                        if (hasCsr1) {
                          if (csr1Controller.text.trim().isEmpty) {
                            showSnackBar("Please enter CSR-1 registration number", false);
                            return;
                          }
                          if (_csr1Image == null) {
                            showSnackBar("Please upload CSR-1 Certificate", false);
                            return;
                          }
                        }
                        if (hasFcra) {
                          if (fcraController.text.trim().isEmpty) {
                            showSnackBar("Please enter FCRA registration number", false);
                            return;
                          }
                          if (_fcraImage == null) {
                            showSnackBar("Please upload FCRA Certificate", false);
                            return;
                          }
                        }

                        final emailToVerify = fillerEmailController.text.trim();
                        final AuthController authCtrl = Get.put(AuthController());
                        bool isAvailable = await authCtrl.checkEmailAvailability(context, emailToVerify);
                        if (!isAvailable) {
                          return;
                        }

                        final List<Map<String, dynamic>> officialsList = officials.map((o) => o.toJson()).toList();

                        Get.toNamed(
                          MyRouters.ngoBankDetailsScreen,
                          arguments: {
                            ...firstScreenData,
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
                            'has12A': has12A ? 'Yes' : 'No',
                            'registration12A': cert12aController.text.trim(),
                            'certificate12A': cert12aImage,
                            'has80G': has80G ? 'Yes' : 'No',
                            'registration80G': cert80gController.text.trim(),
                            'certificate80G': cert80gImage,
                            'hasDarpan': hasDarpan ? 'Yes' : 'No',
                            'darpanNumber': darpanController.text.trim(),
                            'darpanCertificate': _darpanImage,
                            'hasCsr1': hasCsr1 ? 'Yes' : 'No',
                            'csr1Number': csr1Controller.text.trim(),
                            'csr1Certificate': _csr1Image,
                            'hasFcra': hasFcra ? 'Yes' : 'No',
                            'fcraNumber': fcraController.text.trim(),
                            'fcraCertificate': _fcraImage,
                            'websiteUrl': websiteUrlController.text.trim(),
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

  Widget _buildYesNoRadio({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildRadioOptionTile(
            title: "Yes",
            isSelected: value == true,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRadioOptionTile(
            title: "No",
            isSelected: value == false,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOptionTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            const SizedBox(width: 10),
            Text(
              title,
              style: AppFonts.regularText.copyWith(
                fontSize: 13,
                color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildCheckboxOption(String title, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Text(
                title,
                style: AppFonts.regularText.copyWith(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
