import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Controller/home_controller.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/helper.dart';
import 'package:country_picker/country_picker.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/auth_controller.dart';
import '../../Model/profile_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditableAwardItem {
  TextEditingController nameController;
  TextEditingController awardedByController;
  TextEditingController yearController;
  TextEditingController descriptionController;
  File? newDocumentFile;
  String? existingDocUrl;

  EditableAwardItem({
    String name = '',
    String awardedBy = '',
    String year = '',
    String description = '',
    this.existingDocUrl,
    this.newDocumentFile,
  })  : nameController = TextEditingController(text: name),
        awardedByController = TextEditingController(text: awardedBy),
        yearController = TextEditingController(text: year),
        descriptionController = TextEditingController(text: description);

  void dispose() {
    nameController.dispose();
    awardedByController.dispose();
    yearController.dispose();
    descriptionController.dispose();
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shared & Donor controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedGender = "Male";
  File? _imageFile;
  Country _selectedCountry = Country.parse('IN');

  // NGO / Corporate common controllers
  late TextEditingController _orgNameController;
  late TextEditingController _legalNameController;
  late TextEditingController _addressController;
  late TextEditingController _yearsController;
  late TextEditingController _aboutController;
  late TextEditingController _websiteUrlController;
  late TextEditingController _briefProfileController;
  late TextEditingController _authPersonController;
  late TextEditingController _designationController;

  // Corporate specific controllers
  late TextEditingController _csrObligationController;
  late TextEditingController _csrOfficerNameController;
  late TextEditingController _csrOfficerDesignationController;
  late TextEditingController _csrOfficerDeptController;
  late TextEditingController _csrOfficerEmailController;
  late TextEditingController _csrOfficerPhoneController;
  late TextEditingController _csrOfficerLinkedInController;

  String _selectedEmployeeStrength = 'Select Strength';
  List<String> _selectedCsrFocusAreas = [];

  // ===========================================================================
  // NGO-SPECIFIC EDITABLE STATE (Fields 11, 12, 13, 14, 15, 21, 22, 24)
  // ===========================================================================
  // Field 11: 12A Certification (Editable)
  bool _has12A = false;
  File? _cert12aFile;
  String? _existingCert12aUrl;

  // Field 12: 80G Certification (Editable)
  bool _has80G = false;
  File? _cert80gFile;
  String? _existingCert80gUrl;

  // Field 13: DARPAN Registration (Editable)
  bool _hasDarpan = false;
  late TextEditingController _darpanNumberController;
  File? _darpanFile;
  String? _existingDarpanUrl;

  // Field 14: CSR-1 Certification (Editable)
  bool _hasCsr1 = false;
  late TextEditingController _csr1NumberController;
  File? _csr1File;
  String? _existingCsr1Url;

  // Field 15: FCRA Certification (Editable)
  bool _hasFcra = false;
  late TextEditingController _fcraNumberController;
  File? _fcraFile;
  String? _existingFcraUrl;

  // Field 21: Crowdfunded Before (Editable)
  bool _hasCrowdfundedBefore = false;
  late TextEditingController _crowdfundingPlatformController;

  // Field 22: Awards & Recognitions (Editable)
  bool _hasAwards = false;
  final List<EditableAwardItem> _awardsList = [];

  // Field 24: Purpose of fundraising / Causes supported (Editable)
  late TextEditingController _purposeOfFundraisingController;

  @override
  void initState() {
    super.initState();
    final ProfileController profileController = Get.put(ProfileController());

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _orgNameController = TextEditingController();
    _legalNameController = TextEditingController();
    _addressController = TextEditingController();
    _yearsController = TextEditingController();
    _aboutController = TextEditingController();
    _websiteUrlController = TextEditingController();
    _briefProfileController = TextEditingController();
    _authPersonController = TextEditingController();
    _designationController = TextEditingController();
    _csrObligationController = TextEditingController();

    _csrOfficerNameController = TextEditingController();
    _csrOfficerDesignationController = TextEditingController();
    _csrOfficerDeptController = TextEditingController();
    _csrOfficerEmailController = TextEditingController();
    _csrOfficerPhoneController = TextEditingController();
    _csrOfficerLinkedInController = TextEditingController();

    _darpanNumberController = TextEditingController();
    _csr1NumberController = TextEditingController();
    _fcraNumberController = TextEditingController();
    _crowdfundingPlatformController = TextEditingController();
    _purposeOfFundraisingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController authController = Get.put(AuthController());
      authController.fetchMasterSettings();

      profileController.fetchProfile(context, forceRefresh: true).then((_) {
        final p = profileController.profileData.value;
        if (p != null && mounted) {
          _populateDataFromProfile(p);
        }
      });
    });

    final p = profileController.profileData.value;
    if (p != null) {
      _populateDataFromProfile(p);
    }
  }

  void _populateDataFromProfile(ProfileData p) {
    setState(() {
      if (p.organizationName != null && p.organizationName!.isNotEmpty) {
        _orgNameController.text = p.organizationName!;
      }
      if (p.legalName != null && p.legalName!.isNotEmpty) {
        _legalNameController.text = p.legalName!;
      }
      if (p.registeredAddress != null && p.registeredAddress!.isNotEmpty) {
        _addressController.text = p.registeredAddress!;
      }
      final donorName = (p.name != null && p.name!.isNotEmpty)
          ? p.name!
          : (Get.isRegistered<HomeController>() ? Get.find<HomeController>().user?.name ?? '' : '');
      if (donorName.isNotEmpty) {
        _nameController.text = donorName;
      }
      if (p.email != null && p.email!.isNotEmpty) {
        _emailController.text = p.email!;
      }
      if (p.websiteUrl != null && p.websiteUrl!.isNotEmpty) {
        _websiteUrlController.text = p.websiteUrl!;
      }
      if (p.briefProfile != null && p.briefProfile!.isNotEmpty) {
        _briefProfileController.text = p.briefProfile!;
      } else if (p.about != null && p.about!.isNotEmpty) {
        _briefProfileController.text = p.about!;
      }
      if (p.csrObligation != null && p.csrObligation!.isNotEmpty) {
        _csrObligationController.text = p.csrObligation!;
      }
      if (p.authorizedPerson != null && p.authorizedPerson!.isNotEmpty) {
        _authPersonController.text = p.authorizedPerson!;
      }
      if (p.designation != null && p.designation!.isNotEmpty) {
        _designationController.text = p.designation!;
      }
      if (p.phone != null && p.phone!.isNotEmpty) {
        String ph = p.phone!;
        if (ph.startsWith("+91")) {
          _phoneController.text = ph.substring(3).trim();
        } else {
          _phoneController.text = ph;
        }
      }
      if (p.years != null && p.years!.isNotEmpty) {
        _yearsController.text = p.years!;
      } else if (p.impactStats != null && p.impactStats!.isNotEmpty) {
        _yearsController.text = p.impactStats!;
      }
      if (p.about != null && p.about!.isNotEmpty) {
        _aboutController.text = p.about!;
      } else if (p.ourMission != null && p.ourMission!.isNotEmpty) {
        _aboutController.text = p.ourMission!;
      }

      if (p.employeeStrength != null && p.employeeStrength!.isNotEmpty) {
        _selectedEmployeeStrength = p.employeeStrength!;
      }
      if (p.csrFocusAreas is List) {
        _selectedCsrFocusAreas = List<String>.from(p.csrFocusAreas);
      }

      if (p.csrOfficerDetails is Map) {
        final o = p.csrOfficerDetails;
        _csrOfficerNameController.text = o['name'] ?? '';
        _csrOfficerDesignationController.text = o['designation'] ?? '';
        _csrOfficerDeptController.text = o['department'] ?? '';
        _csrOfficerEmailController.text = o['email'] ?? '';
        _csrOfficerPhoneController.text = o['phone'] ?? '';
        _csrOfficerLinkedInController.text = o['linkedInUrl'] ?? '';
      }

      // NGO Specific field initializations
      _has12A = (p.certificate12A != null && p.certificate12A!.isNotEmpty) ||
          (p.registration12A != null && p.registration12A!.isNotEmpty);
      _existingCert12aUrl = p.certificate12A ?? p.registration12A;

      _has80G = (p.certificate80G != null && p.certificate80G!.isNotEmpty) ||
          (p.registration80G != null && p.registration80G!.isNotEmpty);
      _existingCert80gUrl = p.certificate80G ?? p.registration80G;

      _hasDarpan = p.hasDarpan == true ||
          (p.darpanNumber != null && p.darpanNumber!.isNotEmpty) ||
          (p.darpanCertificate != null && p.darpanCertificate!.isNotEmpty);
      _darpanNumberController.text = p.darpanNumber ?? '';
      _existingDarpanUrl = p.darpanCertificate;

      _hasCsr1 = p.hasCSR1 == true ||
          (p.csr1Number != null && p.csr1Number!.isNotEmpty) ||
          (p.csr1Certificate != null && p.csr1Certificate!.isNotEmpty);
      _csr1NumberController.text = p.csr1Number ?? '';
      _existingCsr1Url = p.csr1Certificate;

      _hasFcra = p.hasFCRA == true ||
          (p.fcraNumber != null && p.fcraNumber!.isNotEmpty) ||
          (p.fcraCertificate != null && p.fcraCertificate!.isNotEmpty);
      _fcraNumberController.text = p.fcraNumber ?? '';
      _existingFcraUrl = p.fcraCertificate;

      if (p.hasCrowdfundedBefore != null) {
        final val = p.hasCrowdfundedBefore.toString().toLowerCase();
        _hasCrowdfundedBefore = val == 'yes' || val == 'true' || val == '1';
      }
      _crowdfundingPlatformController.text = p.crowdfundingPlatformsUsed ?? '';

      _purposeOfFundraisingController.text = p.purposeOfFundraising ?? '';

      // Populate awards
      _awardsList.clear();
      final dynamic rawAwards = p.awardsRecognitions;
      if (rawAwards is List && rawAwards.isNotEmpty) {
        _hasAwards = true;
        for (var a in rawAwards) {
          if (a is Map) {
            _awardsList.add(
              EditableAwardItem(
                name: a['name']?.toString() ?? a['title']?.toString() ?? '',
                awardedBy: a['awardedBy']?.toString() ?? '',
                year: a['year']?.toString() ?? '',
                description: a['description']?.toString() ?? '',
                existingDocUrl: a['supportingDocument']?.toString() ?? a['document']?.toString(),
              ),
            );
          }
        }
      } else {
        _hasAwards = false;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();
    _legalNameController.dispose();
    _addressController.dispose();
    _yearsController.dispose();
    _aboutController.dispose();
    _websiteUrlController.dispose();
    _briefProfileController.dispose();
    _authPersonController.dispose();
    _designationController.dispose();
    _csrObligationController.dispose();

    _csrOfficerNameController.dispose();
    _csrOfficerDesignationController.dispose();
    _csrOfficerDeptController.dispose();
    _csrOfficerEmailController.dispose();
    _csrOfficerPhoneController.dispose();
    _csrOfficerLinkedInController.dispose();

    _darpanNumberController.dispose();
    _csr1NumberController.dispose();
    _fcraNumberController.dispose();
    _crowdfundingPlatformController.dispose();
    _purposeOfFundraisingController.dispose();

    for (var a in _awardsList) {
      a.dispose();
    }

    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null) {
      final pickedFile = File(image.path);
      if (await pickedFile.exists()) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    }
  }

  Future<void> _pickDocumentFile(Function(File) onPicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        final f = File(result.files.single.path!);
        if (await f.exists()) {
          onPicked(f);
        }
      }
    } catch (e) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final f = File(image.path);
        if (await f.exists()) {
          onPicked(f);
        }
      }
    }
  }

  void _openDocumentPreview(BuildContext context, String title, String url) {
    if (url.trim().isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (c, u) => Center(
                    child: LoadingAnimationWidget.threeRotatingDots(
                      color: AppTheme.primaryDeepBlue,
                      size: 30,
                    ),
                  ),
                  errorWidget: (c, u, e) => Container(
                    height: 160,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, color: Colors.blueGrey, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            "Document Attached",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 16),
              // ElevatedButton.icon(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppTheme.primaryDeepBlue,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //   ),
              //   onPressed: () {
              //     Clipboard.setData(ClipboardData(text: url));
              //     Navigator.pop(ctx);
              //     showSnackBar("Document link copied", true);
              //   },
              //   icon: const Icon(Icons.copy, size: 16, color: Colors.white),
              //   label: const Text("Copy Link", style: TextStyle(color: Colors.white, fontSize: 13)),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    final AuthController authController = Get.put(AuthController());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme.whiteColor,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(
            AppString.editProfile.tr,
            style: AppFonts.titleStyle.copyWith(fontSize: 18, color: Colors.black87),
          ),
          centerTitle: false,
        ),
        body: Obx(() {
          if (profileController.isLoading.value && profileController.profileData.value == null) {
            return Center(
              child: LoadingAnimationWidget.threeRotatingDots(
                color: AppTheme.primaryDeepBlue,
                size: 50,
              ),
            );
          }

          final p = profileController.profileData.value;
          final String userRole = (p?.role ?? '').toLowerCase();
          final bool isCorporate = userRole == 'corporate';
          final bool isNgo = userRole == 'ngo';
          final bool isDonor = !isCorporate && !isNgo;

          final masterData = authController.masterSettings;
          List<String> focusAreasOptions = masterData?.csrFocusAreas ?? [
            'Education', 'Healthcare', 'Women Empowerment', 'Child Welfare',
            'Senior Citizen Welfare', 'Rural Development', 'Skill Development',
            'Livelihood Development', 'Environmental Sustainability', 'Sanitation & Clean Water',
            'Disaster Management', 'Animal Welfare', 'Sports', 'Art & Culture',
            'Slum Area Development', 'Differently-Abled Persons', 'Research & Development',
            'Armed Forces Veterans', 'Farmers', 'Students', 'Hunger & Poverty', 'Others'
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================================
                  // FIELD 4 FIRST: Logo of your Organization (Editable)
                  // ===========================================================
                  _buildField4Logo(p),
                  const SizedBox(height: 28),

                  if (isDonor) ...[
                    // DONOR FLOW
                    _buildDonorLayout(),
                  ] else if (isCorporate) ...[
                    // CORPORATE FLOW
                    _buildCorporateLayout(p, focusAreasOptions),
                  ] else ...[
                    // =========================================================
                    // NGO FLOW: Sequential implementation according to PDF
                    // Fields 18, 19, 23 EXCLUDED!
                    // Fields 4, 8, 11-16, 20, 21, 22, 24 EDITABLE!
                    // Remaining fields (1, 2, 3, 5, 6, 7, 9, 10, 17, 25) READ-ONLY!
                    // =========================================================
                    _buildNgoLayout(p),
                  ],

                  const SizedBox(height: 36),

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
                      onPressed: () => _handleSaveChanges(isDonor, isCorporate, isNgo, profileController),
                      child: Text(
                        AppString.saveChanges.tr,
                        style: GoogleFonts.poppins(color: AppTheme.whiteColor, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // FIELD 4: Logo of your Organization (SHOWN FIRST & EDITABLE)
  // ===========================================================================
  Widget _buildField4Logo(ProfileData? p) {
    final profilePhoto = p?.profilePhoto ?? p?.logo ?? '';

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.greyBg100,
                    border: Border.all(color: AppTheme.primaryDeepBlue.withValues(alpha: 0.3), width: 3),
                  ),
                  child: ClipOval(
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            key: ValueKey(_imageFile!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Image.asset(AppAssets.appLogo, width: 100, height: 100, fit: BoxFit.cover),
                          )
                        : profilePhoto.isNotEmpty
                            ? CachedNetworkImage(
                                key: ValueKey(profilePhoto),
                                imageUrl: profilePhoto,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => const ShimmerWidget(width: 100, height: 100, borderRadius: BorderRadius.all(Radius.circular(50))),
                                errorWidget: (c, u, e) => Image.asset(AppAssets.appLogo, width: 100, height: 100, fit: BoxFit.cover),
                              )
                            : Image.asset(AppAssets.appLogo, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDeepBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   "Logo of your Organization (Tap to Change)",
          //   style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
          // ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NGO LAYOUT (PDF FIELDS IN STRICT ORDER)
  // ===========================================================================
  Widget _buildNgoLayout(ProfileData? p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field 1: Is your organization a registered Non-Profit? (Read-Only)
        _buildReadOnlyField(
          label: "Is your organization a registered Non-Profit?",
          value: p?.isRegisteredNonProfit ?? p?.organizationType ?? '',
          icon: Icons.business,
        ),
        const SizedBox(height: 18),

        // Field 2: Legal Name of your Organization (Read-Only)
        _buildReadOnlyField(
          label: "Legal Name of your Organization",
          value: p?.legalName ?? p?.organizationName ?? p?.name ?? '',
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 18),

        // Field 3: Registered Address of your Organization (Read-Only + View Document)
        _buildReadOnlyField(
          label: "Registered Address of your Organization",
          value: p?.registeredAddress ?? '',
          docTitle: "Registration Certificate",
          docUrl: p?.addressCertificate,
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 18),

        // Field 5: MOA & AOA / Trust Deed / Society Bye-laws (Read-Only)
        _buildField5ReadOnly(p),
        const SizedBox(height: 18),

        // Field 6: PAN (Read-Only + View Document)
        _buildReadOnlyField(
          label: "PAN",
          value: p?.panNumber ?? '',
          docTitle: "PAN Document",
          docUrl: p?.panImage,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),

        // Field 7: TAN (Read-Only + View Document)
        _buildReadOnlyField(
          label: "TAN",
          value: p?.tanNumber ?? '',
          docTitle: "TAN Document",
          docUrl: p?.tanImage,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),

        // Field 8: Brief Profile of your Organization (EDITABLE)
        _buildEditableTextField(
          label: "Brief Profile of your Organization",
          controller: _briefProfileController,
          hint: "Short description - approx. 150 words",
          maxLines: 4,
          validator: (val) => val == null || val.trim().isEmpty ? "Brief profile is required" : null,
        ),
        const SizedBox(height: 18),

        // Field 9: Directors / Trustees / Key Management (Read-Only)
        _buildField9ReadOnly(p),
        const SizedBox(height: 18),

        // Field 10: Details of the person filling this form (Read-Only)
        _buildField10ReadOnly(p),
        const SizedBox(height: 18),

        // Field 11: Does your Organization have 12A Certification? (EDITABLE)
        _buildCertSelector(
          fieldNumber: "11",
          title: "Does your Organization have 12A Certification?",
          certTitle: "12A Certificate",
          hasCert: _has12A,
          onChanged: (val) => setState(() => _has12A = val),
          selectedFile: _cert12aFile,
          existingUrl: _existingCert12aUrl,
          onPickFile: () => _pickDocumentFile((f) => setState(() => _cert12aFile = f)),
        ),
        const SizedBox(height: 18),

        // Field 12: Does your Organization have 80G Certification? (EDITABLE)
        _buildCertSelector(
          fieldNumber: "12",
          title: "Does your Organization have 80G Certification?",
          certTitle: "80G Certificate",
          hasCert: _has80G,
          onChanged: (val) => setState(() => _has80G = val),
          selectedFile: _cert80gFile,
          existingUrl: _existingCert80gUrl,
          onPickFile: () => _pickDocumentFile((f) => setState(() => _cert80gFile = f)),
        ),
        const SizedBox(height: 18),

        // Field 13: Does your Organization have DARPAN Registration? (EDITABLE)
        _buildCertSelector(
          fieldNumber: "13",
          title: "Does your Organization have DARPAN Registration?",
          certTitle: "DARPAN Certificate",
          hasCert: _hasDarpan,
          onChanged: (val) => setState(() => _hasDarpan = val),
          numberController: _darpanNumberController,
          numberHint: "Enter DARPAN Registration Number",
          selectedFile: _darpanFile,
          existingUrl: _existingDarpanUrl,
          onPickFile: () => _pickDocumentFile((f) => setState(() => _darpanFile = f)),
        ),
        const SizedBox(height: 18),

        // Field 14: Does your Organization have CSR-1 Certification? (EDITABLE)
        _buildCertSelector(
          fieldNumber: "14",
          title: "Does your Organization have CSR-1 Certification?",
          certTitle: "CSR-1 Certificate",
          hasCert: _hasCsr1,
          onChanged: (val) => setState(() => _hasCsr1 = val),
          numberController: _csr1NumberController,
          numberHint: "Enter CSR-1 Registration Number",
          selectedFile: _csr1File,
          existingUrl: _existingCsr1Url,
          onPickFile: () => _pickDocumentFile((f) => setState(() => _csr1File = f)),
        ),
        const SizedBox(height: 18),

        // Field 15: Does your Organization have FCRA Certification? (EDITABLE)
        _buildCertSelector(
          fieldNumber: "15",
          title: "Does your Organization have FCRA Certification?",
          certTitle: "FCRA Certificate",
          hasCert: _hasFcra,
          onChanged: (val) => setState(() => _hasFcra = val),
          numberController: _fcraNumberController,
          numberHint: "Enter FCRA Registration Number",
          selectedFile: _fcraFile,
          existingUrl: _existingFcraUrl,
          onPickFile: () => _pickDocumentFile((f) => setState(() => _fcraFile = f)),
        ),
        const SizedBox(height: 18),

        // Field 16: Website URL of your Organization (EDITABLE)
        _buildEditableTextField(
          label: "Website URL of your Organization",
          controller: _websiteUrlController,
          hint: "https://example.org",
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 18),

        // Field 17: Bank Details of your Organization (Read-Only)
        _buildField17ReadOnly(p),
        const SizedBox(height: 18),

        // Fields 18 and 19 are EXCLUDED from Edit Profile UI!

        // Field 20: What is your organization's total employee strength? (EDITABLE)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What is your organization's total employee strength?",
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              _selectedEmployeeStrength,
              ['Select Strength', '0 - 25', '25 - 100', 'More than 100'],
              (val) => setState(() => _selectedEmployeeStrength = val!),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Field 21: Have you crowdfunded before? (EDITABLE)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Have you crowdfunded before?",
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRadioOption("Yes", _hasCrowdfundedBefore, () => setState(() => _hasCrowdfundedBefore = true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRadioOption("No", !_hasCrowdfundedBefore, () => setState(() => _hasCrowdfundedBefore = false)),
                ),
              ],
            ),
            if (_hasCrowdfundedBefore) ...[
              const SizedBox(height: 12),
              _buildEditableTextField(
                label: "Mention name of Crowdfunding Platform Used",
                controller: _crowdfundingPlatformController,
                hint: "Platform name",
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),

        // Field 22: Awards & Recognitions (EDITABLE)
        _buildField22Editable(),
        const SizedBox(height: 18),

        // Field 23 is EXCLUDED from Edit Profile UI!

        // Field 24: Purpose of fundraising/ Cause/s Supported (EDITABLE)
        _buildEditableTextField(
          label: "Purpose of fundraising/ Cause/s Supported",
          controller: _purposeOfFundraisingController,
          hint: "Mention your main area/s of work in 80 words",
          maxLines: 3,
        ),
        const SizedBox(height: 18),

        // Field 25: Compliance & Declarations (Read-Only)
        _buildField25ReadOnly(),
      ],
    );
  }

  // ===========================================================================
  // FIELD 5 (READ-ONLY)
  // ===========================================================================
  Widget _buildField5ReadOnly(ProfileData? p) {
    final dynamic docs = p?.moaAoaDocuments;
    List<String> docList = [];
    if (docs is List) {
      docList = docs.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    } else if (docs != null && docs.toString().trim().isNotEmpty) {
      docList = [docs.toString().trim()];
    }

    return _buildReadOnlyContainer(
      label: "MOA & AOA / Trust Deed / Society Bye-laws",
      child: docList.isNotEmpty
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: docList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                return _buildDocChip("Document $idx", entry.value);
              }).toList(),
            )
          : Text("No documents attached", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  // ===========================================================================
  // FIELD 9 (READ-ONLY)
  // ===========================================================================
  Widget _buildField9ReadOnly(ProfileData? p, {String label = "Directors / Trustees / Key Management"}) {
    final dynamic officialsRaw = p?.directorsKeyManagement;
    List<Map<String, dynamic>> officialsList = [];

    if (officialsRaw is List) {
      for (var item in officialsRaw) {
        if (item is Map) {
          officialsList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return _buildReadOnlyContainer(
      label: label,
      child: officialsList.isNotEmpty
          ? Column(
              children: officialsList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final off = entry.value;
                final name = off['name']?.toString() ?? off['fullName']?.toString() ?? 'Official $idx';
                final designation = off['designation']?.toString() ?? off['role']?.toString() ?? '-';
                final email = off['email']?.toString() ?? '-';
                final pan = off['pan']?.toString() ?? '-';
                final aadhar = off['aadharId']?.toString() ?? off['aadhar']?.toString() ?? '-';
                final linkedIn = off['linkedInUrl']?.toString() ?? off['linkedIn']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Text("Designation: $designation | Email: $email", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                      Text("PAN: $pan | Aadhar: $aadhar", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                      if (linkedIn.isNotEmpty)
                        Text("LinkedIn: $linkedIn", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1D4ED8))),
                    ],
                  ),
                );
              }).toList(),
            )
          : Text("No directors / key management recorded", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  // ===========================================================================
  // FIELD 10 (READ-ONLY)
  // ===========================================================================
  Widget _buildField10ReadOnly(ProfileData? p) {
    Map<String, dynamic> filler = {};
    if (p?.formFillerDetails is Map) {
      filler = Map<String, dynamic>.from(p!.formFillerDetails);
    }

    final name = filler['name']?.toString() ?? p?.authorizedPerson ?? '';
    final designation = filler['designationRole']?.toString() ?? filler['designation']?.toString() ?? p?.designation ?? '';
    final phone = filler['phone']?.toString() ?? p?.phone ?? '';
    final email = filler['email']?.toString() ?? p?.email ?? '';
    final pan = filler['pan']?.toString() ?? '';
    final aadhar = filler['aadharId']?.toString() ?? filler['aadhar']?.toString() ?? '';
    final authLetter = p?.authorityLetter ?? filler['authorityLetter']?.toString() ?? '';

    final hasContent = name.isNotEmpty || email.isNotEmpty || phone.isNotEmpty;

    return _buildReadOnlyContainer(
      label: "Details of the person filling this form",
      child: hasContent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${name.isNotEmpty ? name : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Designation: ${designation.isNotEmpty ? designation : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Phone: ${phone.isNotEmpty ? formatPhoneWithCountryCode(phone) : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Email: ${email.isNotEmpty ? email : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("PAN: ${pan.isNotEmpty ? pan : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Aadhar: ${aadhar.isNotEmpty ? aadhar : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                if (authLetter.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildDocChip("Authority Letter", authLetter),
                ],
              ],
            )
          : Text("Not Provided", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  // ===========================================================================
  // FIELD 17 (READ-ONLY)
  // ===========================================================================
  Widget _buildField17ReadOnly(ProfileData? p) {
    final bankName = p?.bankName ?? '';
    final branch = p?.bankBranch ?? '';
    final holder = p?.bankAccountHolder ?? '';
    final accNo = p?.bankAccountNumber ?? '';
    final ifsc = p?.bankIFSC ?? '';
    final chequeUrl = p?.cancelledChequeDoc ?? '';

    final hasBank = bankName.isNotEmpty || accNo.isNotEmpty;

    return _buildReadOnlyContainer(
      label: "Bank Details of your Organization",
      child: hasBank
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("a) Bank: ${bankName.isNotEmpty ? bankName : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                Text("b) Branch: ${branch.isNotEmpty ? branch : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                Text("c) Account Name: ${holder.isNotEmpty ? holder : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                Text("d) Account No: ${accNo.isNotEmpty ? accNo : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                Text("e) IFSC: ${ifsc.isNotEmpty ? ifsc : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                if (chequeUrl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildDocChip("Cancelled Cheque / Passbook", chequeUrl),
                ],
              ],
            )
          : Text("Not Provided", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  // ===========================================================================
  // FIELD 22: Awards & Recognitions (EDITABLE)
  // ===========================================================================
  Widget _buildField22Editable({String title = "Awards & Recognitions"}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRadioOption("Yes", _hasAwards, () {
                setState(() {
                  _hasAwards = true;
                  if (_awardsList.isEmpty) {
                    _awardsList.add(EditableAwardItem());
                  }
                });
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption("No", !_hasAwards, () => setState(() => _hasAwards = false)),
            ),
          ],
        ),
        if (_hasAwards) ...[
          const SizedBox(height: 12),
          Column(
            children: _awardsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final award = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Award #${idx + 1}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              award.dispose();
                              _awardsList.removeAt(idx);
                              if (_awardsList.isEmpty) {
                                _hasAwards = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(label: "Name of the Award/ Recognition", controller: award.nameController, hint: "Award Name"),
                    const SizedBox(height: 8),
                    _buildInputField(label: "Awarded/ Recognised by", controller: award.awardedByController, hint: "Organisation / Authority"),
                    const SizedBox(height: 8),
                    _buildInputField(label: "Year", controller: award.yearController, hint: "YYYY", keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    _buildInputField(label: "Brief Description", controller: award.descriptionController, hint: "Description (optional)", maxLines: 2),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryDeepBlue,
                            side: BorderSide(color: AppTheme.primaryDeepBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _pickDocumentFile((f) => setState(() => award.newDocumentFile = f)),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: Text(award.newDocumentFile != null ? "Change Doc" : "Upload Doc", style: const TextStyle(fontSize: 12)),
                        ),
                        if (award.newDocumentFile != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Selected: ${award.newDocumentFile!.path.split('/').last}",
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else if (award.existingDocUrl != null && award.existingDocUrl!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildDocChip("Current Document", award.existingDocUrl!),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryDeepBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => setState(() => _awardsList.add(EditableAwardItem())),
            icon: Icon(Icons.add, size: 16, color: AppTheme.primaryDeepBlue),
            label: Text("Add Another Award", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryDeepBlue)),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // FIELD 25 (READ-ONLY)
  // ===========================================================================
  Widget _buildField25ReadOnly() {
    final declarations = [
      "Documents submitted are genuine and the information filled above is true & accurate.",
      "Donations will be used only for declared purposes and not for any prohibited activities.",
      "Organization will maintain proper records and provide utilisation reports where required.",
      "Organization agrees to the platform's Privacy Policy and Fundraising Terms & Conditions.",
      "Organization agrees to the KYC requirements and verification/ audit by the platform.",
      "Organization understands that fundraising campaigns may be suspended pending verification.",
    ];

    return _buildReadOnlyContainer(
      label: "Compliance & Declarations",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: declarations.map((dec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00875A), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dec,
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569), height: 1.35),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================================================================
  // CERTIFICATION SELECTOR (Fields 11, 12, 13, 14, 15 - Editable)
  // ===========================================================================
  Widget _buildCertSelector({
    required String fieldNumber,
    required String title,
    required String certTitle,
    required bool hasCert,
    required ValueChanged<bool> onChanged,
    TextEditingController? numberController,
    String? numberHint,
    File? selectedFile,
    String? existingUrl,
    required VoidCallback onPickFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildRadioOption("Yes", hasCert, () => onChanged(true))),
            const SizedBox(width: 12),
            Expanded(child: _buildRadioOption("No", !hasCert, () => onChanged(false))),
          ],
        ),
        if (hasCert) ...[
          const SizedBox(height: 10),
          if (numberController != null) ...[
            _buildEditableTextField(
              label: "Registration Number",
              controller: numberController,
              hint: numberHint ?? "Registration Number",
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDeepBlue,
                  side: BorderSide(color: AppTheme.primaryDeepBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: onPickFile,
                icon: const Icon(Icons.upload_file, size: 16),
                label: Text(selectedFile != null ? "Change File" : "Upload File", style: const TextStyle(fontSize: 12)),
              ),
              if (selectedFile != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Selected: ${selectedFile.path.split('/').last}",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else if (existingUrl != null && existingUrl.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDocChip("$certTitle", existingUrl),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // SAVE CHANGES HANDLER
  // ===========================================================================
  Future<void> _handleSaveChanges(bool isDonor, bool isCorporate, bool isNgo, ProfileController profileController) async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> updateMap = {};

    if (isDonor) {
      updateMap = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "gender": _selectedGender,
      };
    } else if (isCorporate) {
      // CORPORATE FLOW: Only save editable fields (4, 9, 12, 13, 15, 20)
      OverlayEntry loader = Helpers.overlayLoader(context);
      Overlay.of(context).insert(loader);

      try {
        List<Map<String, dynamic>> finalAwards = [];
        if (_hasAwards) {
          for (var item in _awardsList) {
            String? docUrl = item.existingDocUrl;
            if (item.newDocumentFile != null) {
              final uploaded = await profileController.uploadFile(item.newDocumentFile!);
              if (uploaded != null && uploaded.isNotEmpty) {
                docUrl = uploaded;
              }
            }
            finalAwards.add({
              'name': item.nameController.text.trim(),
              'title': item.nameController.text.trim(),
              'awardedBy': item.awardedByController.text.trim(),
              'year': item.yearController.text.trim(),
              'description': item.descriptionController.text.trim(),
              if (docUrl != null && docUrl.isNotEmpty) 'supportingDocument': docUrl,
              if (docUrl != null && docUrl.isNotEmpty) 'document': docUrl,
            });
          }
        }

        updateMap = {
          "briefProfile": _briefProfileController.text.trim(),
          "about": _briefProfileController.text.trim(),
          "websiteUrl": _websiteUrlController.text.trim(),
          "csrObligation": _csrObligationController.text.trim(),
          "csrFocusAreas": _selectedCsrFocusAreas,
          "hasAwards": _hasAwards ? "Yes" : "No",
          "awardsRecognitions": finalAwards,
          "awards": finalAwards,
        };

        Helpers.hideLoader(loader);
      } catch (e) {
        Helpers.hideLoader(loader);
        showSnackBar("Failed to save changes: $e", false);
        return;
      }
    } else {
      // NGO FLOW: Only save editable fields (4, 8, 11-16, 20, 21, 22, 24)
      OverlayEntry loader = Helpers.overlayLoader(context);
      Overlay.of(context).insert(loader);

      try {
        // Upload new certificate files if picked
        String? cert12aUrl = _existingCert12aUrl;
        if (_has12A && _cert12aFile != null) {
          final up = await profileController.uploadFile(_cert12aFile!);
          if (up != null) cert12aUrl = up;
        }

        String? cert80gUrl = _existingCert80gUrl;
        if (_has80G && _cert80gFile != null) {
          final up = await profileController.uploadFile(_cert80gFile!);
          if (up != null) cert80gUrl = up;
        }

        String? darpanUrl = _existingDarpanUrl;
        if (_hasDarpan && _darpanFile != null) {
          final up = await profileController.uploadFile(_darpanFile!);
          if (up != null) darpanUrl = up;
        }

        String? csr1Url = _existingCsr1Url;
        if (_hasCsr1 && _csr1File != null) {
          final up = await profileController.uploadFile(_csr1File!);
          if (up != null) csr1Url = up;
        }

        String? fcraUrl = _existingFcraUrl;
        if (_hasFcra && _fcraFile != null) {
          final up = await profileController.uploadFile(_fcraFile!);
          if (up != null) fcraUrl = up;
        }

        // Process awards
        List<Map<String, dynamic>> finalAwardsList = [];
        if (_hasAwards) {
          for (var item in _awardsList) {
            String? docUrl = item.existingDocUrl;
            if (item.newDocumentFile != null) {
              final up = await profileController.uploadFile(item.newDocumentFile!);
              if (up != null) docUrl = up;
            }
            finalAwardsList.add({
              'name': item.nameController.text.trim(),
              'awardedBy': item.awardedByController.text.trim(),
              'year': item.yearController.text.trim(),
              'description': item.descriptionController.text.trim(),
              'supportingDocument': docUrl ?? '',
            });
          }
        }

        updateMap = {
          // Field 8: Brief Profile
          "briefProfile": _briefProfileController.text.trim(),
          "about": _briefProfileController.text.trim(),
          "ourMission": _briefProfileController.text.trim(),

          // Field 11: 12A
          "has12A": _has12A,
          "certificate12A": _has12A ? (cert12aUrl ?? '') : '',
          "registration12A": _has12A ? (cert12aUrl ?? '') : '',

          // Field 12: 80G
          "has80G": _has80G,
          "certificate80G": _has80G ? (cert80gUrl ?? '') : '',
          "registration80G": _has80G ? (cert80gUrl ?? '') : '',

          // Field 13: DARPAN
          "hasDarpan": _hasDarpan,
          "darpanNumber": _hasDarpan ? _darpanNumberController.text.trim() : '',
          "darpanCertificate": _hasDarpan ? (darpanUrl ?? '') : '',

          // Field 14: CSR-1
          "hasCSR1": _hasCsr1,
          "csr1Number": _hasCsr1 ? _csr1NumberController.text.trim() : '',
          "csr1Certificate": _hasCsr1 ? (csr1Url ?? '') : '',

          // Field 15: FCRA
          "hasFCRA": _hasFcra,
          "fcraNumber": _hasFcra ? _fcraNumberController.text.trim() : '',
          "fcraCertificate": _hasFcra ? (fcraUrl ?? '') : '',

          // Field 16: Website URL
          "websiteUrl": _websiteUrlController.text.trim(),

          // Field 20: Employee Strength
          "employeeStrength": _selectedEmployeeStrength != 'Select Strength' ? _selectedEmployeeStrength : '',

          // Field 21: Crowdfunded Before
          "hasCrowdfundedBefore": _hasCrowdfundedBefore ? 'Yes' : 'No',
          "crowdfundingPlatformsUsed": _hasCrowdfundedBefore ? _crowdfundingPlatformController.text.trim() : '',

          // Field 22: Awards & Recognitions
          "hasAwards": _hasAwards ? 'Yes' : 'No',
          "awards": _hasAwards ? finalAwardsList : [],
          "awardsRecognitions": _hasAwards ? finalAwardsList : [],

          // Field 24: Purpose of fundraising
          "purposeOfFundraising": _purposeOfFundraisingController.text.trim(),
        };
      } finally {
        Helpers.hideLoader(loader);
      }
    }

    if (!mounted) return;

    bool success = await profileController.updateProfile(
      context: context,
      imageFile: _imageFile,
      mapData: updateMap,
    );

    if (success) {
      if (mounted) {
        setState(() {
          _imageFile = null;
          _cert12aFile = null;
          _cert80gFile = null;
          _darpanFile = null;
          _csr1File = null;
          _fcraFile = null;
        });
      }
      Get.back();
      showSnackBar(AppString.profileUpdatedSuccessfully.tr, true);
    }
  }

  // ===========================================================================
  // DONOR & CORPORATE LAYOUT HELPERS (PRESERVED)
  // ===========================================================================
  Widget _buildDonorLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.personalDetails.tr,
          style: AppFonts.semiBoldText.copyWith(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInputField(label: "Full Name", controller: _nameController, hint: "Enter Your Full Name"),
        const SizedBox(height: 16),
        _buildInputField(label: "Email Address", controller: _emailController, hint: "Enter Your Email Address", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        Text("Select Your Gender", style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderButton(label: "Female", icon: Icons.female, isSelected: _selectedGender == "Female", onTap: () => setState(() => _selectedGender = "Female"))),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderButton(label: "Male", icon: Icons.male, isSelected: _selectedGender == "Male", onTap: () => setState(() => _selectedGender = "Male"))),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderButton(label: "Other", isSelected: _selectedGender == "Other", onTap: () => setState(() => _selectedGender = "Other"))),
          ],
        ),
      ],
    );
  }

  String _cleanRegistrationType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String text = raw.trim();
    if (text.toLowerCase().startsWith('yes - as a ')) {
      text = text.substring(11).trim();
    } else if (text.toLowerCase().startsWith('yes - ')) {
      text = text.substring(6).trim();
    }
    return text;
  }

  // ===========================================================================
  // CORPORATE LAYOUT (PDF FIELDS IN STRICT ORDER: 1-3, 5-13, 15-21)
  // Field 4 (Logo) is at top; Field 14 is EXCLUDED completely;
  // Fields 4, 9, 12, 13, 15, 20 are EDITABLE; all others are READ-ONLY.
  // ===========================================================================
  Widget _buildCorporateLayout(ProfileData? p, List<String> focusAreasOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field 1: Is your organization a registered Company? (Read-Only)
        _buildReadOnlyField(
          label: "Is your organization a registered Company?",
          value: _cleanRegistrationType(p?.isRegisteredCompany ?? p?.isRegisteredNonProfit ?? p?.organizationType ?? ''),
          icon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 18),

        // Field 2: Legal Name of your Organization (Read-Only)
        _buildReadOnlyField(
          label: "Legal Name of your Organization",
          value: p?.legalName ?? p?.organizationName ?? p?.name ?? '',
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 18),

        // Field 3: Registered Address of your Organization (Read-Only + View Document)
        _buildReadOnlyField(
          label: "Registered Address of your Organization",
          value: p?.registeredAddress ?? '',
          docTitle: "Registration Certificate",
          docUrl: p?.addressCertificate,
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 18),

        // Field 4 (Logo) is rendered at the top of the form (Editable)

        // Field 5: MOA & AOA / LLP Agreement/ Partnership Deed (Read-Only)
        _buildField5CorporateReadOnly(p),
        const SizedBox(height: 18),

        // Field 6: PAN of your Organization (Read-Only + View Document)
        _buildReadOnlyField(
          label: "PAN of your Organization",
          value: p?.panNumber ?? '',
          docTitle: "PAN Document",
          docUrl: p?.panImage,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),

        // Field 7: TAN of your Organization (Read-Only + View Document)
        _buildReadOnlyField(
          label: "TAN of your Organization",
          value: p?.tanNumber ?? '',
          docTitle: "TAN Document",
          docUrl: p?.tanImage,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),

        // Field 8: GST of your Organization (Read-Only + View Document)
        _buildReadOnlyField(
          label: "GST of your Organization",
          value: p?.gstNumber ?? '',
          docTitle: "GST Certificate",
          docUrl: p?.gstDocument,
          icon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: 18),

        // Field 9: Brief Profile of your Organization (EDITABLE)
        _buildEditableTextField(
          label: "Brief Profile of your Organization",
          controller: _briefProfileController,
          hint: "Short description - approx. 150 words",
          maxLines: 4,
          validator: (val) => val == null || val.trim().isEmpty ? "Brief profile is required" : null,
        ),
        const SizedBox(height: 18),

        // Field 10: Directors / Partners / Key Management (Read-Only)
        _buildField9ReadOnly(p, label: "Directors / Partners / Key Management"),
        const SizedBox(height: 18),

        // Field 11: Details of the person filling this form (Read-Only)
        _buildField10ReadOnly(p),
        const SizedBox(height: 18),

        // Field 12: Website URL of your Organization (EDITABLE)
        _buildEditableTextField(
          label: "Website URL of your Organization",
          controller: _websiteUrlController,
          hint: "https://example.com",
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 18),

        // Field 13: Last Financial Year's CSR Obligation (EDITABLE)
        _buildEditableTextField(
          label: "Last Financial Year's CSR Obligation",
          controller: _csrObligationController,
          hint: "Mention CSR obligation briefly",
          maxLines: 2,
        ),
        const SizedBox(height: 18),

        // Field 14: EXCLUDED completely from Corporate Edit Profile

        // Field 15: What are your organization's CSR focus areas? (EDITABLE)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What are your organization's CSR focus areas?",
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: focusAreasOptions.map((area) {
                bool isSelected = _selectedCsrFocusAreas.contains(area);
                return FilterChip(
                  label: Text(
                    area,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryDeepBlue : const Color(0xFF334155),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryDeepBlue.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primaryDeepBlue,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryDeepBlue : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCsrFocusAreas.add(area);
                      } else {
                        _selectedCsrFocusAreas.remove(area);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Field 16: What are your organization's funding preferences? (Read-Only)
        _buildReadOnlyField(
          label: "What are your organization's funding preferences?",
          value: p?.fundingPreferences?.toString() ?? '',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 18),

        // Field 17: Banking & Financial Details (for CSR commitments & payments) (Read-Only)
        _buildField17CorporateReadOnly(p),
        const SizedBox(height: 18),

        // Field 18: Details of CSR officer of your organization (Read-Only)
        _buildField18CorporateReadOnly(p),
        const SizedBox(height: 18),

        // Field 19: What is your organization's total employee strength? (Read-Only)
        _buildReadOnlyField(
          label: "What is your organization's total employee strength?",
          value: p?.employeeStrength ?? '',
          icon: Icons.groups_outlined,
        ),
        const SizedBox(height: 18),

        // Field 20: Corporate Recognition & Awards (EDITABLE)
        _buildField22Editable(title: "Corporate Recognition & Awards"),
        const SizedBox(height: 18),

        // Field 21: Compliance & Declarations (Read-Only)
        _buildField21CorporateDeclarationsReadOnly(),
      ],
    );
  }

  Widget _buildField5CorporateReadOnly(ProfileData? p) {
    final dynamic moa = p?.moaAoaDocuments;
    List<String> docs = [];
    if (moa is List) {
      docs = moa.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (moa is String && moa.trim().isNotEmpty) {
      docs = [moa.trim()];
    }

    return _buildReadOnlyContainer(
      label: "MOA & AOA / LLP Agreement/ Partnership Deed",
      child: docs.isNotEmpty
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: docs.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                return _buildDocChip("Document $idx", entry.value);
              }).toList(),
            )
          : Text("No documents attached", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildField17CorporateReadOnly(ProfileData? p) {
    final bankName = p?.bankName ?? '';
    final branch = p?.bankBranch ?? '';
    final holder = p?.bankAccountHolder ?? '';
    final accNo = p?.bankAccountNumber ?? '';
    final ifsc = p?.bankIFSC ?? '';
    final chequeUrl = p?.cancelledChequeDoc ?? '';

    final hasBank = bankName.isNotEmpty || accNo.isNotEmpty;

    return _buildReadOnlyContainer(
      label: "Banking & Financial Details (for CSR commitments & payments)",
      child: hasBank
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bank Name: ${bankName.isNotEmpty ? bankName : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Branch: ${branch.isNotEmpty ? branch : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Account Holder: ${holder.isNotEmpty ? holder : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Account Number: ${accNo.isNotEmpty ? accNo : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("IFSC Code: ${ifsc.isNotEmpty ? ifsc : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                if (chequeUrl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildDocChip("Cancelled Cheque", chequeUrl),
                ],
              ],
            )
          : Text("Not Provided", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildField18CorporateReadOnly(ProfileData? p) {
    Map<String, dynamic> officer = {};
    if (p?.csrOfficerDetails is Map) {
      officer = Map<String, dynamic>.from(p!.csrOfficerDetails);
    }
    final name = officer['name']?.toString() ?? '';
    final desig = officer['designation']?.toString() ?? '';
    final dept = officer['department']?.toString() ?? '';
    final email = officer['email']?.toString() ?? '';
    final phone = officer['phone']?.toString() ?? '';
    final linkedIn = officer['linkedInUrl']?.toString() ?? officer['linkedIn']?.toString() ?? '';

    final hasOfficer = name.isNotEmpty || email.isNotEmpty || phone.isNotEmpty;

    return _buildReadOnlyContainer(
      label: "Details of CSR officer of your organization",
      child: hasOfficer
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${name.isNotEmpty ? name : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Designation: ${desig.isNotEmpty ? desig : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Department: ${dept.isNotEmpty ? dept : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Phone: ${phone.isNotEmpty ? formatPhoneWithCountryCode(phone) : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text("Email: ${email.isNotEmpty ? email : '-'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E293B))),
                if (linkedIn.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text("LinkedIn: $linkedIn", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1D4ED8))),
                ],
              ],
            )
          : Text("Not Provided", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildField21CorporateDeclarationsReadOnly() {
    final declarations = [
      "Documents submitted are genuine and the information filled above is true & accurate.",
      "The representative is authorised to register the organization.",
      "Organization agrees to the platform's Privacy Policy and Terms & Conditions.",
      "Organization agrees to the KYC requirements and verification/ audit by the platform.",
      "Organization understands that the platform may request additional documents.",
    ];

    return _buildReadOnlyContainer(
      label: "Compliance & Declarations",
      child: Column(
        children: declarations.map((dec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dec,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF065F46),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================================================================
  // COMMON UI WIDGETS
  // ===========================================================================
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? docTitle,
    String? docUrl,
    IconData? icon,
  }) {
    final hasVal = value.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 10, color: Colors.black54),
                  const SizedBox(width: 2),
                  Text("Read-only", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      hasVal ? value : "Not Provided",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: hasVal ? const Color(0xFF1E293B) : Colors.grey.shade400,
                        fontStyle: hasVal ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              if (docTitle != null && docUrl != null && docUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDocChip(docTitle, docUrl),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 10, color: Colors.black54),
                  const SizedBox(width: 2),
                  Text("Read-only", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDocChip(String title, String url) {
    return InkWell(
      onTap: () => _openDocumentPreview(context, title, url),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF1D4ED8)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                "View $title",
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryDeepBlue : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? AppTheme.primaryDeepBlue : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryDeepBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.fieldBorderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.fieldBorderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.primaryDeepBlue, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
  }) {
    bool isPhone = keyboardType == TextInputType.phone || label.toLowerCase().contains('phone');
    final bool isEditable = !readOnly && enabled;

    Widget fieldWidget = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      enabled: enabled,
      maxLength: maxLength ?? (isPhone ? 10 : null),
      inputFormatters: inputFormatters ?? (isPhone ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ] : null),
      decoration: InputDecoration(
        hintText: hint,
        counterText: isPhone ? "" : null,
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
      validator: validator,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        if (isPhone)
          Row(
            children: [
              GestureDetector(
                onTap: isEditable
                    ? () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                        );
                      }
                    : null,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isEditable ? Colors.white : const Color(0xFFF1F5F9),
                    border: Border.all(color: AppTheme.fieldBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        "+${_selectedCountry.phoneCode}",
                        style: AppFonts.semiBoldText.copyWith(
                          fontSize: 13,
                          color: isEditable ? AppTheme.blackColor : AppTheme.textGrey400,
                        ),
                      ),
                      const SizedBox(width: 2),
                      if (isEditable)
                        Icon(Icons.arrow_drop_down, color: AppTheme.textGrey400)
                      else
                        Icon(Icons.lock_outline, size: 13, color: AppTheme.textGrey400),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: fieldWidget),
            ],
          )
        else
          fieldWidget,
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : items.first,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppFonts.regularText.copyWith(
                  color: item.startsWith('Select') ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
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
}
