import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/custom_button.dart';
import '../../Utilities/custom_textfield.dart';
import '../../Utilities/custom_appbar.dart';
import '../../Utilities/helper.dart';
import '../../Controller/auth_controller.dart';

class AwardDetail {
  TextEditingController nameController = TextEditingController();
  TextEditingController awardedByController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? documentFile;

  Map<String, dynamic> toJson() {
    return {
      'name': nameController.text.trim(),
      'awardedBy': awardedByController.text.trim(),
      'year': yearController.text.trim(),
      'description': descriptionController.text.trim(),
      'supportingDocument': documentFile,
    };
  }

  void dispose() {
    nameController.dispose();
    awardedByController.dispose();
    yearController.dispose();
    descriptionController.dispose();
  }
}

class NgoBankDetailsScreen extends StatefulWidget {
  const NgoBankDetailsScreen({super.key});

  @override
  State<NgoBankDetailsScreen> createState() => _NgoBankDetailsScreenState();
}

class _NgoBankDetailsScreenState extends State<NgoBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Item 17: Bank Details
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchAddressController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  File? _cancelledCheque;

  // Item 18: Last Financial Year's Budget (NGO)
  String selectedBudget = '0 - 25 Lakhs';

  // Item 19: Total Donor Database Strength (NGO)
  String selectedDonorStrength = '0 - 500';

  // Item 20: What is your organization's total employee strength? (NGO)
  String selectedEmployeeStrength = '0 - 25';

  // Item 21: Have you crowdfunded before? (NGO)
  bool hasCrowdfunded = false;
  final TextEditingController crowdfundingPlatformsController = TextEditingController();

  // Item 22: Awards & Recognitions (Common)
  bool hasAwards = false;
  List<AwardDetail> awards = [];

  // Item 23: How soon are you planning to create a fundraising campaign on our platform? (NGO)
  String selectedTimeframe = '0 - 5 days';

  // Item 24: Purpose of fundraising/ Cause/s Supported (NGO)
  final TextEditingController purposeOfFundraisingController = TextEditingController();

  // Item 25: Compliance & Declarations (NGO)
  bool dec1GenuineInfo = false;
  bool dec2DeclaredPurposesOnly = false;
  bool dec3MaintainRecords = false;
  bool dec4AgreesPrivacyPolicy = false;
  bool dec5AgreesKycAudit = false;
  bool dec6SuspensionUnderstood = false;

  // ==========================================
  // Corporate Flow Fields (Items 14 to 21)
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

  // Item 18: Details of CSR officer of your organization:
  final TextEditingController csrOfficerNameController = TextEditingController();
  final TextEditingController csrOfficerDesignationController = TextEditingController();
  final TextEditingController csrOfficerDepartmentController = TextEditingController();
  final TextEditingController csrOfficerEmailController = TextEditingController();
  final TextEditingController csrOfficerPhoneController = TextEditingController();
  final TextEditingController csrOfficerLinkedInController = TextEditingController();

  // Item 19: What is your organization’s total employee strength? (Corporate options)
  String selectedCorporateEmployeeStrength = '0 - 500';

  // Item 21: Compliance & Declarations (Corporate - 5 checkboxes)
  bool corpDec1 = false;
  bool corpDec2 = false;
  bool corpDec3 = false;
  bool corpDec4 = false;
  bool corpDec5 = false;

  late Map<String, dynamic> combinedData;
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
    combinedData = Get.arguments ?? {};
    role = (combinedData['role'] ?? 'ngo').toString().toLowerCase();
    isCorporate = (role == 'corporate');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController authController = Get.put(AuthController());
      if (authController.masterSettings == null) {
        authController.fetchMasterSettings();
      }
    });
  }

  @override
  void dispose() {
    bankNameController.dispose();
    branchAddressController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();

    crowdfundingPlatformsController.dispose();
    for (var a in awards) {
      a.dispose();
    }
    purposeOfFundraisingController.dispose();

    otherCsrFocusController.dispose();
    csrOfficerNameController.dispose();
    csrOfficerDesignationController.dispose();
    csrOfficerDepartmentController.dispose();
    csrOfficerEmailController.dispose();
    csrOfficerPhoneController.dispose();
    csrOfficerLinkedInController.dispose();

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
          titleText: 'Baking Details',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                if (isCorporate) ...[
                  // ==========================================
                  // CORPORATE FLOW (Items 17 to 21 from PDF)
                  // ==========================================

                  // 17. Banking & Financial Details (for CSR commitments & payments):
                  Text(
                    "Banking & Financial Details (for CSR commitments & payments):",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildBankDetailsContainer(),
                  const SizedBox(height: 20),

                  // 18. Details of CSR officer of your organization:
                  Text(
                    "Details of CSR officer of your organization:",
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
                        Text("a) Name", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerNameController,
                          hintText: "Enter Name",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter name' : null,
                        ),
                        const SizedBox(height: 12),

                        Text("b) Designation", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerDesignationController,
                          hintText: "Enter Designation",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter designation' : null,
                        ),
                        const SizedBox(height: 12),

                        Text("c) Department", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerDepartmentController,
                          hintText: "Enter Department",
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter department' : null,
                        ),
                        const SizedBox(height: 12),

                        Text("d) E-mail ID", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerEmailController,
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

                        Text("e) Phone Number", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerPhoneController,
                          hintText: "Enter Phone Number",
                          keyboardType: TextInputType.phone,
                          inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
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

                        Text("f) LinkedIn/ Other Official Profile", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
                          const SizedBox(height: 4),
                        CommonTextField(
                          controller: csrOfficerLinkedInController,
                          hintText: "Enter Profile URL",
                          keyboardType: TextInputType.url,
                          useBorder: true,
                          borderColor: AppTheme.fieldBorderColor,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 19. What is your organization’s total employee strength?
                  Text(
                    "What is your organization’s total employee strength?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 500', '500 - 1000', 'More than 1000'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedCorporateEmployeeStrength,
                      onChanged: (val) => setState(() => selectedCorporateEmployeeStrength = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 20. Corporate Recognition & Awards
                  Text(
                    "Corporate Recognition & Awards",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Has your organization received any award, honour, recognition or appreciation for its CSR initiatives, social impact, sustainability practices or community development work from the Government of India, any State Government, or any reputed organization/ institution?",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  _buildYesNoRadio(
                    value: hasAwards,
                    onChanged: (val) {
                      setState(() {
                        hasAwards = val;
                        if (hasAwards && awards.isEmpty) {
                          awards.add(AwardDetail());
                        }
                      });
                    },
                  ),
                  if (hasAwards) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Please provide details:",
                      style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(awards.length, (index) => _buildAwardItem(index)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            awards.add(AwardDetail());
                          });
                        },
                        icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryDeepBlue),
                        label: Text(
                          "Add Another Award",
                          style: AppFonts.mediumText.copyWith(color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 21. Compliance & Declarations:
                  Text(
                    "Compliance & Declarations:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildCheckboxOption(
                    "Documents submitted are genuine and the information filled above is true & accurate.",
                    corpDec1,
                    (val) => setState(() => corpDec1 = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "The representative is authorised to register the organization.",
                    corpDec2,
                    (val) => setState(() => corpDec2 = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization agrees to the platform’s Privacy Policy and Terms & Conditions.",
                    corpDec3,
                    (val) => setState(() => corpDec3 = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization agrees to the KYC requirements and verification/ audit by the platform.",
                    corpDec4,
                    (val) => setState(() => corpDec4 = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization understands that the platform may request additional documents.",
                    corpDec5,
                    (val) => setState(() => corpDec5 = val ?? false),
                  ),
                ] else ...[
                  // ==========================================
                  // NGO FLOW (Items 17 to 25 from NGO PDF)
                  // ==========================================

                  // 17. Bank Details of your Organization:
                  Text(
                    "Bank Details of your Organization:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildBankDetailsContainer(),
                  const SizedBox(height: 24),

                  // 18. Last Financial Year’s Budget:
                  Text(
                    "Last Financial Year’s Budget:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 25 Lakhs', '25 Lakhs - 1 Crore', 'More than 1 Crore'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedBudget,
                      onChanged: (val) => setState(() => selectedBudget = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 19. Total Donor Database Strength:
                  Text(
                    "Total Donor Database Strength:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 500', '500 - 1000', 'More than 1000'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedDonorStrength,
                      onChanged: (val) => setState(() => selectedDonorStrength = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 20. What is your organization’s total employee strength?
                  Text(
                    "What is your organization’s total employee strength?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 25', '25 - 100', 'More than 100'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedEmployeeStrength,
                      onChanged: (val) => setState(() => selectedEmployeeStrength = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 21. Have you crowdfunded before?
                  Text(
                    "Have you crowdfunded before?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  _buildYesNoRadio(
                    value: hasCrowdfunded,
                    onChanged: (val) => setState(() => hasCrowdfunded = val),
                  ),
                  if (hasCrowdfunded) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Mention name of Crowdfunding Platform Used",
                      style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500),
                    ),
                    const SizedBox(height: 4),
                    CommonTextField(
                      controller: crowdfundingPlatformsController,
                      hintText: "Enter platform name(s)",
                      useBorder: true,
                      borderColor: AppTheme.fieldBorderColor,
                      borderRadius: 10,
                      validator: (val) {
                        if (hasCrowdfunded && (val == null || val.trim().isEmpty)) {
                          return 'Please mention crowdfunding platform used';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 22. Awards & Recognitions:
                  Text(
                    "Awards & Recognitions:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Has your Organization received any award, honour, recognition or appreciation for its social work or community service from the Government of India, any State Government, or any other reputed organization/ Institute?",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  _buildYesNoRadio(
                    value: hasAwards,
                    onChanged: (val) {
                      setState(() {
                        hasAwards = val;
                        if (hasAwards && awards.isEmpty) {
                          awards.add(AwardDetail());
                        }
                      });
                    },
                  ),

                  if (hasAwards) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Please provide details:",
                      style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(awards.length, (index) => _buildAwardItem(index)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            awards.add(AwardDetail());
                          });
                        },
                        icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryDeepBlue),
                        label: Text(
                          "Add Another Award",
                          style: AppFonts.mediumText.copyWith(color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 23. How soon are you planning to create a fundraising campaign on our platform?
                  Text(
                    "How soon are you planning to create a fundraising campaign on our platform?",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ...['0 - 5 days', '5 - 15 days', 'More than 15 days'].map((opt) {
                    return _buildRadioOption(
                      title: opt,
                      value: opt,
                      groupValue: selectedTimeframe,
                      onChanged: (val) => setState(() => selectedTimeframe = val),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 24. Purpose of fundraising/ Cause/s Supported
                  Text(
                    "Purpose of fundraising/ Cause/s Supported",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "(Mention your main area/s of work in 80 words)",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(
                    controller: purposeOfFundraisingController,
                    hintText: "Mention your main area/s of work...",
                    maxLines: 3,
                    useBorder: true,
                    borderColor: AppTheme.fieldBorderColor,
                    borderRadius: 10,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter purpose of fundraising' : null,
                  ),
                  const SizedBox(height: 28),

                  // 25. Compliance & Declarations:
                  Text(
                    "Compliance & Declarations:",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildCheckboxOption(
                    "Documents submitted are genuine and the information filled above is true & accurate.",
                    dec1GenuineInfo,
                    (val) => setState(() => dec1GenuineInfo = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Donations will be used only for declared purposes and not for any prohibited activities.",
                    dec2DeclaredPurposesOnly,
                    (val) => setState(() => dec2DeclaredPurposesOnly = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization will maintain proper records and provide utilisation reports where required.",
                    dec3MaintainRecords,
                    (val) => setState(() => dec3MaintainRecords = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization agrees to the platform’s Privacy Policy and Fundraising Terms & Conditions.",
                    dec4AgreesPrivacyPolicy,
                    (val) => setState(() => dec4AgreesPrivacyPolicy = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization agrees to the KYC requirements and verification/ audit by the platform.",
                    dec5AgreesKycAudit,
                    (val) => setState(() => dec5AgreesKycAudit = val ?? false),
                  ),
                  _buildCheckboxOption(
                    "Organization understands that fundraising campaigns may be suspended pending verification.",
                    dec6SuspensionUnderstood,
                    (val) => setState(() => dec6SuspensionUnderstood = val ?? false),
                  ),
                ],

                const SizedBox(height: 36),

                // Submit Button
                GetBuilder<AuthController>(
                  init: AuthController(),
                  builder: (authCtrl) {
                    return CustomButton(
                      height: 50,
                      width: double.infinity,
                      title: "Submit Registration",
                      showLoader: authCtrl.isLoading,
                      onTap: () {
                        if (authCtrl.isLoading) return;
                        if (_formKey.currentState!.validate()) {
                          if (isCorporate) {
                            // Field 17 (f): Cancelled Cheque / Passbook
                            if (_cancelledCheque == null) {
                              showSnackBar("Please upload Cancelled Cheque / Passbook Image", false);
                              return;
                            }

                            // Field 19: Total Employee Strength
                            if (selectedCorporateEmployeeStrength.trim().isEmpty) {
                              showSnackBar("Please select total employee strength", false);
                              return;
                            }

                            // Field 20: Corporate Recognition & Awards (conditional on Yes, Brief Description remains optional)
                            if (hasAwards) {
                              if (awards.isEmpty) {
                                showSnackBar("Please provide award details", false);
                                return;
                              }
                              for (int i = 0; i < awards.length; i++) {
                                final awd = awards[i];
                                if (awd.nameController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Name of Award ${i + 1}", false);
                                  return;
                                }
                                if (awd.awardedByController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Awarding Authority for Award ${i + 1}", false);
                                  return;
                                }
                                if (awd.yearController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Year for Award ${i + 1}", false);
                                  return;
                                }
                                // Brief description remains optional
                                if (awd.documentFile == null) {
                                  showSnackBar("Please upload Supporting Document for Award ${i + 1}", false);
                                  return;
                                }
                              }
                            }

                            // Field 21: Compliance & Declarations
                            if (!corpDec1 || !corpDec2 || !corpDec3 || !corpDec4 || !corpDec5) {
                              showSnackBar("Please agree to all Compliance & Declarations", false);
                              return;
                            }
                          } else {
                            // Field 17 (f): Cancelled Cheque / Passbook
                            if (_cancelledCheque == null) {
                              showSnackBar("Please upload Cancelled Cheque / Passbook Image", false);
                              return;
                            }

                            // Fields 18, 19, 20: Budget, Donor Database, Employee Strength
                            if (selectedBudget.trim().isEmpty) {
                              showSnackBar("Please select last financial year's budget", false);
                              return;
                            }
                            if (selectedDonorStrength.trim().isEmpty) {
                              showSnackBar("Please select total donor database strength", false);
                              return;
                            }
                            if (selectedEmployeeStrength.trim().isEmpty) {
                              showSnackBar("Please select total employee strength", false);
                              return;
                            }

                            // Field 21: Crowdfunding platform used (conditional on Yes)
                            if (hasCrowdfunded && crowdfundingPlatformsController.text.trim().isEmpty) {
                              showSnackBar("Please mention name of crowdfunding platform used", false);
                              return;
                            }

                            // Field 22: Awards & Recognitions (conditional on Yes, Brief Description remains optional)
                            if (hasAwards) {
                              if (awards.isEmpty) {
                                showSnackBar("Please provide award details", false);
                                return;
                              }
                              for (int i = 0; i < awards.length; i++) {
                                final awd = awards[i];
                                if (awd.nameController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Name of Award ${i + 1}", false);
                                  return;
                                }
                                if (awd.awardedByController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Awarding Authority for Award ${i + 1}", false);
                                  return;
                                }
                                if (awd.yearController.text.trim().isEmpty) {
                                  showSnackBar("Please enter Year for Award ${i + 1}", false);
                                  return;
                                }
                                // Brief description remains optional
                                if (awd.documentFile == null) {
                                  showSnackBar("Please upload Supporting Document for Award ${i + 1}", false);
                                  return;
                                }
                              }
                            }

                            // Field 23: Planning timeframe
                            if (selectedTimeframe.trim().isEmpty) {
                              showSnackBar("Please select fundraising planning timeframe", false);
                              return;
                            }

                            // Field 24: Purpose of fundraising
                            if (purposeOfFundraisingController.text.trim().isEmpty) {
                              showSnackBar("Please enter purpose of fundraising / causes supported", false);
                              return;
                            }

                            // Field 25: Compliance & Declarations
                            if (!dec1GenuineInfo ||
                                !dec2DeclaredPurposesOnly ||
                                !dec3MaintainRecords ||
                                !dec4AgreesPrivacyPolicy ||
                                !dec5AgreesKycAudit ||
                                !dec6SuspensionUnderstood) {
                              showSnackBar("Please agree to all Compliance & Declarations", false);
                              return;
                            }
                          }

                          List<Map<String, dynamic>> awardsList = hasAwards ? awards.map((a) => a.toJson()).toList() : [];

                          final Map<String, dynamic> finalNgoData = {...combinedData,
                            'bankAccountHolder': accountNameController.text.trim(),
                            'bankName': bankNameController.text.trim(),
                            'bankBranch': branchAddressController.text.trim(),
                            'bankAccountNumber': accountNumberController.text.trim(),
                            'bankIFSC': ifscCodeController.text.trim(),
                            'cancelledChequeDoc': _cancelledCheque,
                            if (isCorporate) ...{
                              'csrAmountSpentPreviousYear': combinedData['csrAmountSpent'] ?? selectedCsrAmountSpent,
                              'csrFocusAreas': combinedData['csrFocusAreas'] ?? selectedCsrFocusAreas.toList(),
                              'otherCsrFocusArea': combinedData['otherCsrFocus'] ?? otherCsrFocusController.text.trim(),
                              'fundingPreference': combinedData['fundingPreference'] ?? selectedFundingPreference,
                              'csrOfficer': {
                                'name': csrOfficerNameController.text.trim(),
                                'designation': csrOfficerDesignationController.text.trim(),
                                'department': csrOfficerDepartmentController.text.trim(),
                                'email': csrOfficerEmailController.text.trim(),
                                'phone': csrOfficerPhoneController.text.trim(),
                                'linkedIn': csrOfficerLinkedInController.text.trim(),
                              },
                              'employeeStrength': selectedCorporateEmployeeStrength,
                              'hasAwards': hasAwards ? 'Yes' : 'No',
                              'awards': awardsList,
                              'complianceDeclarations': {
                                'infoTrueAccurate': corpDec1,
                                'representativeAuthorised': corpDec2,
                                'privacyPolicyAgreed': corpDec3,
                                'kycAuditAgreed': corpDec4,
                                'additionalDocumentsUnderstood': corpDec5,
                              },
                            } else ...{
                              'lastFinancialYearBudget': selectedBudget,
                              'donorDatabaseStrength': selectedDonorStrength,
                              'employeeStrength': selectedEmployeeStrength,
                              'hasCrowdfundedBefore': hasCrowdfunded ? 'Yes' : 'No',
                              'crowdfundingPlatformsUsed': crowdfundingPlatformsController.text.trim(),
                              'hasAwards': hasAwards ? 'Yes' : 'No',
                              'awards': awardsList,
                              'campaignPlanningTimeframe': selectedTimeframe,
                              'purposeOfFundraising': purposeOfFundraisingController.text.trim(),
                              'complianceDeclarations': {
                                'infoTrueAccurate': dec1GenuineInfo,
                                'declaredPurposesOnly': dec2DeclaredPurposesOnly,
                                'maintainRecords': dec3MaintainRecords,
                                'privacyPolicyAgreed': dec4AgreesPrivacyPolicy,
                                'kycAgreed': dec5AgreesKycAudit,
                                'suspensionUnderstood': dec6SuspensionUnderstood,
                              },
                            },
                          };

                          authCtrl.registerNgo(
                            context: context,
                            ngoData: finalNgoData,
                            bankAccountHolder: accountNameController.text.trim(),
                            bankName: bankNameController.text.trim(),
                            bankBranch: branchAddressController.text.trim(),
                            bankAccountNumber: accountNumberController.text.trim(),
                            bankIFSC: ifscCodeController.text.trim(),
                            cancelledChequeDoc: _cancelledCheque,
                          );
                        }
                      },
                      color: AppTheme.primaryDeepBlue,
                      borderRadius: BorderRadius.circular(10),
                      showCenter: true,
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // a) Name of the bank
          Text("a) Name of the bank", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: bankNameController,
            hintText: "Enter Name of Bank",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter bank name' : null,
          ),
          const SizedBox(height: 12),

          // b) Branch Address
          Text("b) Branch Address", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: branchAddressController,
            hintText: "Enter Branch Address",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter branch address' : null,
          ),
          const SizedBox(height: 12),

          // c) Account Name
          Text("c) Account Name", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: accountNameController,
            hintText: "Enter Account Name",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter account name' : null,
          ),
          const SizedBox(height: 12),

          // d) Current A/c No.
          Text("d) Current A/c No.", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: accountNumberController,
            hintText: "Enter Current Account Number",
            keyboardType: TextInputType.number,
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter account number' : null,
          ),
          const SizedBox(height: 12),

          // e) IFSC Code
          Text("e) IFSC Code", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: ifscCodeController,
            hintText: "Enter IFSC Code",
            inputFormatters: [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              upperCaseFormatter,
            ],
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter IFSC code';
              if (val.trim().length != 11) return 'IFSC code must be 11 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // f) Cancelled Cheque/ Passbook (i-text: Upload Cancelled Cheque/ Passbook Image)
          Text("f) Cancelled Cheque/ Passbook", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          // const SizedBox(height: 2),
          // Text("(Upload Cancelled Cheque/ Passbook Image)", style: AppFonts.regularText.copyWith(fontSize: 11, color: AppTheme.textGrey500)),
          _buildFileUploadBox(
            label: 'Upload Cancelled Cheque / Passbook Image',
            file: _cancelledCheque,
            onTap: () => _pickDocumentOrImage(
              onFilePicked: (f) => setState(() => _cancelledCheque = f),
            ),
            onRemove: () => setState(() => _cancelledCheque = null),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardItem(int index) {
    final awd = awards[index];
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
                "Award ${index + 1}",
                style: AppFonts.mediumText.copyWith(fontSize: 14, color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.w600),
              ),
              if (awards.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      awards.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),

          Text("Name of the Award/ Recognition", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: awd.nameController,
            hintText: "Enter Name of Award",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: hasAwards
                ? (val) => val == null || val.trim().isEmpty ? 'Please enter name of award' : null
                : null,
          ),
          const SizedBox(height: 12),

          Text("Awarded/ Recognised by", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: awd.awardedByController,
            hintText: "Enter Awarding Authority",
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: hasAwards
                ? (val) => val == null || val.trim().isEmpty ? 'Please enter awarding authority' : null
                : null,
          ),
          const SizedBox(height: 12),

          Text("Year", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: awd.yearController,
            hintText: "YYYY",
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(4), FilteringTextInputFormatter.digitsOnly],
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
            validator: hasAwards
                ? (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter year';
                    if (val.trim().length != 4) return 'Year must be 4 digits';
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 12),

          Text("Brief Description", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          const SizedBox(height: 4),
          CommonTextField(
            controller: awd.descriptionController,
            hintText: "Brief Description",
            maxLines: 2,
            useBorder: true,
            borderColor: AppTheme.fieldBorderColor,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),

          Text("Supporting Document/ Certificate Upload", style: AppFonts.smallText.copyWith(color: AppTheme.textGrey500)),
          _buildFileUploadBox(
            label: 'Upload Award Document',
            file: awd.documentFile,
            onTap: () => _pickDocumentOrImage(
              onFilePicked: (f) => setState(() => awd.documentFile = f),
            ),
            onRemove: () => setState(() => awd.documentFile = null),
          ),
        ],
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
                style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87, height: 1.35),
              ),
            ),
          ),
        ],
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
}
