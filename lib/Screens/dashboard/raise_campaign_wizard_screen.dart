import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Utilities/app_assets.dart';
import '../../Routes/my_routes.dart';
import '../../Repo/common_repo.dart';
import '../../Utilities/api_constant.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Model/campaign_details_model.dart';
import '../../Utilities/helper.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Controller/active_campaigns_controller.dart';
import '../../Controller/my_campaigns_controller.dart';
import 'package:country_picker/country_picker.dart';
import 'main_navigation_screen.dart';

class RaiseCampaignWizardScreen extends StatefulWidget {
  const RaiseCampaignWizardScreen({super.key});

  @override
  State<RaiseCampaignWizardScreen> createState() => _RaiseCampaignWizardScreenState();
}

class _RaiseCampaignWizardScreenState extends State<RaiseCampaignWizardScreen> {
  final PageController _pageController = PageController();
  final quill.QuillController _storyController = quill.QuillController.basic();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Country _selectedCountry = Country.parse('IN');
  DateTime? _selectedDateTime;
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  String? _selectedCategory;

  List<String> _categories = [];
  bool _isLoadingCategories = false;

  final ImagePicker _picker = ImagePicker();
  File? _mainImage;
  final List<File?> _smallImages = List.filled(5, null);
  final List<File> _identityDocs = [];
  final List<File> _medicalDocs = [];

  int _currentStep = 0;
  final ValueNotifier<int> _storyLengthNotifier = ValueNotifier<int>(0);
  final FocusNode _storyFocusNode = FocusNode();

  // Edit Mode state
  bool _isEdit = false;
  String? _editCampaignId;
  bool _isLoadingDetails = false;
  String? _existingMainImageUrl;
  List<String> _existingSmallImageUrls = [];
  List<String> _existingIdentityDocUrls = [];
  List<String> _existingMedicalDocUrls = [];
  String? _existingStatus;
  String? _existingVideo;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map) {
      _isEdit = args['isEdit'] == true;
      _editCampaignId = args['campaignId']?.toString();
    }

    _fetchCampaignCategories();
    _storyController.addListener(() {
      int length = _storyController.document.toPlainText().length - 1;
      _storyLengthNotifier.value = length > 0 ? length : 0;
    });

    if (_isEdit && _editCampaignId != null && _editCampaignId!.isNotEmpty) {
      _fetchCampaignDetailsForEdit(_editCampaignId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());
      final userRole = (profileCtrl.profileData.value?.role ?? '').toLowerCase();
      if (userRole == 'corporate') {
        showSnackBar("Corporate users cannot raise campaigns", false);
        if (Navigator.canPop(context)) {
          Get.back();
        } else {
          mainNavKey.currentState?.changeTab(0);
        }
      }
    });
  }

  Future<void> _fetchCampaignDetailsForEdit(String id) async {
    setState(() {
      _isLoadingDetails = true;
    });
    try {
      final response = await Repositories().getApi(
        url: ApiUrls.getCampaignDetailsUrl(id),
        showResponse: true,
      );
      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = CampaignDetailsModel.fromJson(jsonResponse);
        final data = model.data;
        if (data != null && mounted) {
          setState(() {
            _titleController.text = data.title ?? '';
            _selectedCategory = data.category;
            final mob = data.mobile ?? (jsonResponse['data']?['mobile']?.toString() ?? jsonResponse['data']?['phone']?.toString() ?? '');
            if (mob.isNotEmpty) {
              if (mob.startsWith('+')) {
                final clean = mob.replaceFirst('+', '');
                if (clean.startsWith('91') && clean.length > 2) {
                  _selectedCountry = Country.parse('IN');
                  _mobileController.text = clean.substring(2).trim();
                } else {
                  _mobileController.text = mob;
                }
              } else {
                _mobileController.text = mob;
              }
            } else {
              _mobileController.text = '';
            }
            _emailController.text = data.email ?? (jsonResponse['data']?['email']?.toString() ?? '');

            // Extract numeric target amount
            final rawGoal = data.goal ?? '';
            final goalDigits = rawGoal.replaceAll(RegExp(r'[^0-9]'), '');
            _amountController.text = goalDigits.isNotEmpty ? goalDigits : rawGoal;

            // End date
            if (data.endDate != null && data.endDate!.isNotEmpty) {
              final parsedDate = DateTime.tryParse(data.endDate!);
              if (parsedDate != null) {
                _selectedDateTime = parsedDate;
                _dateController.text = "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
              }
            }

            // Description / Story
            final desc = data.description ?? '';
            if (desc.isNotEmpty) {
              _storyController.document = quill.Document()..insert(0, desc);
              _storyLengthNotifier.value = _storyController.document.toPlainText().length - 1;
            }

            // Cover and additional images
            _existingMainImageUrl = data.imageUrl ?? (data.images != null && data.images!.isNotEmpty ? data.images!.first : null);
            if (data.images != null && data.images!.isNotEmpty) {
              _existingSmallImageUrls = data.images!.where((img) => img != _existingMainImageUrl).toList();
            }

            // Documents
            if (data.verificationDocs != null && data.verificationDocs!.isNotEmpty) {
              _existingIdentityDocUrls = List<String>.from(data.verificationDocs!);
              if (data.documents != null && data.documents!.isNotEmpty) {
                _existingMedicalDocUrls = data.documents!
                    .where((doc) => !_existingIdentityDocUrls.contains(doc))
                    .toList();
              } else {
                _existingMedicalDocUrls = [];
              }
            } else if (data.documents != null && data.documents!.isNotEmpty) {
              final bool hasExplicitTags = data.documents!.any(
                (doc) => doc.contains('#type=identity') || doc.contains('#type=medical'),
              );

              if (hasExplicitTags) {
                _existingIdentityDocUrls = data.documents!
                    .where((doc) => doc.contains('#type=identity'))
                    .toList();
                _existingMedicalDocUrls = data.documents!
                    .where((doc) => doc.contains('#type=medical'))
                    .toList();
                for (var doc in data.documents!) {
                  if (!_existingIdentityDocUrls.contains(doc) && !_existingMedicalDocUrls.contains(doc)) {
                    _existingMedicalDocUrls.add(doc);
                  }
                }
              } else {
                // Backward compatibility: previous campaigns without tags saved identity proof as first document
                _existingIdentityDocUrls = [data.documents!.first];
                if (data.documents!.length > 1) {
                  _existingMedicalDocUrls = data.documents!.sublist(1);
                } else {
                  _existingMedicalDocUrls = [];
                }
              }
            } else {
              _existingIdentityDocUrls = [];
              _existingMedicalDocUrls = [];
            }

            // Bank details
            if (data.bankDetails != null) {
              _holderNameController.text = data.bankDetails?.holderName ?? '';
              _bankNameController.text = data.bankDetails?.bankName ?? '';
              _accountNumberController.text = data.bankDetails?.accountNumber ?? '';
              _ifscCodeController.text = data.bankDetails?.ifscCode ?? '';
            }

            _existingStatus = data.status ?? 'Live';
            _existingVideo = data.video ?? 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching campaign details for edit: $e");
      showSnackBar("Failed to load campaign details: $e", false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _fetchCampaignCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final response = await Repositories().getApi(
        url: ApiUrls.campaignCategoriesUrl,
        showResponse: true,
      );
      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          final List<String> fetchedNames = data
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          if (mounted) {
            setState(() {
              _categories = fetchedNames;
              _isLoadingCategories = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching campaign categories: $e");
    }
    if (mounted) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _storyController.dispose();
    _storyFocusNode.dispose();
    _dateController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _holderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _storyLengthNotifier.dispose();
    super.dispose();
  }

  void _clearFields() {
    if (!mounted) return;
    setState(() {
      _titleController.clear();
      _amountController.clear();
      _dateController.clear();
      _mobileController.clear();
      _emailController.clear();
      _selectedCountry = Country.parse('IN');
      _holderNameController.clear();
      _bankNameController.clear();
      _accountNumberController.clear();
      _ifscCodeController.clear();
      _selectedCategory = null;
      _selectedDateTime = null;
      _mainImage = null;
      for (int i = 0; i < _smallImages.length; i++) {
        _smallImages[i] = null;
      }
      _identityDocs.clear();
      _medicalDocs.clear();
      _existingMainImageUrl = null;
      _existingSmallImageUrls.clear();
      _existingIdentityDocUrls.clear();
      _existingMedicalDocUrls.clear();
      _isEdit = false;
      _editCampaignId = null;
      _currentStep = 0;
      _storyController.document = quill.Document();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryDeepBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
        // Format as dd/mm/yyyy
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  Future<void> _pickSmallImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _smallImages[index] = File(image.path);
      });
    }
  }

  Future<void> _pickIdentityDoc() async {
    _showPickerOptions((file) {
      setState(() {
        _identityDocs.add(file);
      });
    });
  }

  Future<void> _pickMedicalDoc() async {
    _showPickerOptions((file) {
      setState(() {
        _medicalDocs.add(file);
      });
    });
  }

  void _showPickerOptions(Function(File) onFilePicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Pick Image from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    onFilePicked(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Pick PDF Document'),
                onTap: () async {
                  Navigator.of(context).pop();
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
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

  final List<String> _stepTitles = [
    AppString.stepInformation.tr,
    AppString.stepUploadImages.tr,
    AppString.stepVerification.tr,
    AppString.stepBankDetails.tr,
  ];

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        showSnackBar("Please enter a campaign title.", false);
        return;
      }
      if (_selectedCategory == null) {
        showSnackBar("Please select a campaign category.", false);
        return;
      }
      if (_amountController.text.trim().isEmpty) {
        showSnackBar("Please enter a target amount.", false);
        return;
      }
      if (_amountController.text.trim().length > 10) {
        showSnackBar("Target amount cannot be more than 10 digits", false);
        return;
      }
      if (_dateController.text.trim().isEmpty) {
        showSnackBar("Please select an end date.", false);
        return;
      }
      if (_mobileController.text.trim().isEmpty) {
        showSnackBar("Please enter mobile number.", false);
        return;
      }
      if (_mobileController.text.trim().length != 10) {
        showSnackBar("Please enter a valid 10-digit mobile number.", false);
        return;
      }
      final emailText = _emailController.text.trim();
      if (emailText.isEmpty) {
        showSnackBar("Please enter email address.", false);
        return;
      }
      if (!GetUtils.isEmail(emailText) || !RegExp(r"^[\w\.\-]+@[\w\-]+(\.[a-zA-Z]{2,})+$").hasMatch(emailText)) {
        showSnackBar("Please enter a valid email address.", false);
        return;
      }
      if (_storyController.document.toPlainText().trim().isEmpty) {
        showSnackBar("Please write a campaign story.", false);
        return;
      }
    } else if (_currentStep == 1) {
      if (_mainImage == null && (_existingMainImageUrl == null || _existingMainImageUrl!.isEmpty)) {
        showSnackBar("Please upload a cover image.", false);
        return;
      }
    } else if (_currentStep == 2) {
      if (!_isEdit && _identityDocs.isEmpty && _existingIdentityDocUrls.isEmpty) {
        showSnackBar("Please upload identity proof.", false);
        return;
      }
      if (_medicalDocs.isEmpty && _existingMedicalDocUrls.isEmpty) {
        showSnackBar("Please upload medical documents.", false);
        return;
      }
    }

    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetails) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text("Edit Campaign", style: AppFonts.titleStyle.copyWith(fontSize: 18)),
          centerTitle: false,
        ),
        body: Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: AppTheme.primaryDeepBlue,
            size: 40,
          ),
        ),
      );
    }

    final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());
    final userRole = (profileCtrl.profileData.value?.role ?? '').toLowerCase();
    if (userRole == 'corporate') {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(_isEdit ? "Edit Campaign" : AppString.raiseACampaign.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
          centerTitle: false,
        ),
        body: Center(
          child: Text(
            "Corporate users cannot raise campaigns.",
            style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              )
            : (_isEdit
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                    onPressed: () => Get.back(),
                  )
                : null),
        title: Text(_isEdit ? "Edit Campaign" : AppString.raiseACampaign.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildInformationStep(),
                _buildUploadImagesStep(),
                _buildVerificationStep(),
                _buildBankDetailsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_stepTitles.length, (index) {
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: index == 0
                          ? const SizedBox(height: 2)
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CustomPaint(
                                size: const Size(double.infinity, 2),
                                painter: _DottedLinePainter(
                                  color: index <= _currentStep ? AppTheme.progressGreen : AppTheme.fieldBorderColor,
                                ),
                              ),
                            ),
                    ),
                    _buildStepIndicator(index),
                    Expanded(
                      child: index == _stepTitles.length - 1
                          ? const SizedBox(height: 2)
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CustomPaint(
                                size: const Size(double.infinity, 2),
                                painter: _DottedLinePainter(
                                  color: index < _currentStep ? AppTheme.progressGreen : AppTheme.fieldBorderColor,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _stepTitles[index],
                  style: AppFonts.regularText.copyWith(
                    fontSize: 10,
                    color: index <= _currentStep ? Colors.black87 : AppTheme.textGrey400,
                    fontWeight: index <= _currentStep ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    if (index < _currentStep) {
      // Completed step
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.progressGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    } else if (index == _currentStep) {
      // Current step
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: Center(
          child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      );
    } else {
      // Pending step
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.fieldBorderColor, width: 2),
        ),
        child: Center(
          child: Text("${index + 1}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey400)),
        ),
      );
    }
  }

  Widget _buildInformationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.tellUsAboutCampaign.tr, style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 24),
          _buildTextField(AppString.campaignTitle.tr, AppString.enterTitle.tr, controller: _titleController),
          const SizedBox(height: 16),
          _buildDropdownField(
            AppString.campaignCategory.tr,
            AppString.selectCategory.tr,
            _selectedCategory,
            _categories,
            (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            AppString.targetAmount.tr,
            AppString.enterAmount.tr,
            prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(AppString.endDate.tr, AppString.selectDate.tr, suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey), controller: _dateController, readOnly: true, onTap: () => _selectDate(context)),
          const SizedBox(height: 16),
          _buildMobileField(),
          const SizedBox(height: 16),
          _buildTextField(
            "Email Address",
            "Enter Email Address",
            prefixIcon: const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          Text(AppString.campaignStory.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF1976D2), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tip: Personal stories increase funding success by up to 40%. Be authentic and transparent.",
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: const Color(0xFF1976D2), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rich Text Toolbar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.fieldBorderColor),
            ),
            child: quill.QuillSimpleToolbar(
              controller: _storyController,
              config: const quill.QuillSimpleToolbarConfig(
                iconTheme: quill.QuillIconTheme(
                  iconButtonUnselectedData: quill.IconButtonData(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  iconButtonSelectedData: quill.IconButtonData(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
                buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                  base: quill.QuillToolbarBaseButtonOptions(
                    iconSize: 15,
                    iconButtonFactor: 1.25,
                  ),
                ),
                showFontFamily: false,
                showFontSize: false,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: false,
                showInlineCode: false,
                showStrikeThrough: false,
                showClearFormat: false,
                showSearchButton: false,
                showIndent: false,
                showSubscript: false,
                showSuperscript: false,
                showListNumbers: false,
                showColorButton: true,
                showBackgroundColorButton: false,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showAlignmentButtons: true,
                showListBullets: true,
                showLink: false,
                showUndo: false,
                showRedo: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.fieldBorderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: quill.QuillEditor.basic(
              controller: _storyController,
              focusNode: _storyFocusNode,
              config: quill.QuillEditorConfig(
                placeholder: "We need another and a wiser and perhaps a more mystical concept of animals...",
                customStyles: quill.DefaultStyles(
                  placeHolder: quill.DefaultTextBlockStyle(
                    const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: _storyLengthNotifier,
            builder: (context, length, child) {
              return Text(
                "${1000 - length} characters left",
                style: AppFonts.regularText.copyWith(
                  fontSize: 10,
                  color: length >= 1000 ? Colors.red : Colors.grey,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildUploadImagesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.stepUploadImages.tr, style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(AppString.coverImages.tr.replaceAll('*', ''), style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickMainImage,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: AppTheme.fieldBorderColor,
                      strokeWidth: 2,
                      dashPattern: const <double>[6, 4],
                      radius: const Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 210,
                      width: double.infinity,
                      child: _mainImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_mainImage!, fit: BoxFit.cover),
                            )
                          : (_existingMainImageUrl != null && _existingMainImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: _existingMainImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (ctx, url, err) => Image.asset(AppAssets.campaignImage, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text("Change", style: TextStyle(color: Colors.white, fontSize: 11)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add, color: Colors.grey, size: 28),
                                    const SizedBox(height: 8),
                                    Text(AppString.mainPhoto.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.grey)),
                                  ],
                                )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildSmallImageSlot(0),
                    const SizedBox(height: 12),
                    _buildSmallImageSlot(1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSmallImageSlot(2)),
              const SizedBox(width: 12),
              Expanded(child: _buildSmallImageSlot(3)),
              const SizedBox(width: 12),
              Expanded(child: _buildSmallImageSlot(4)),
            ],
          ),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildSmallImageSlot(int index) {
    bool hasFile = _smallImages[index] != null;
    bool hasExisting = index < _existingSmallImageUrls.length && _existingSmallImageUrls[index].isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _pickSmallImage(index),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppTheme.fieldBorderColor,
          strokeWidth: 2,
          dashPattern: const <double>[6, 4],
          radius: const Radius.circular(12),
        ),
        child: SizedBox(
          height: 98,
          width: double.infinity,
          child: hasFile
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_smallImages[index]!, fit: BoxFit.cover),
                )
              : (hasExisting
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: _existingSmallImageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (ctx, url, err) => Image.asset(AppAssets.campaignImage, fit: BoxFit.cover),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.add, color: Colors.grey, size: 24),
                    )),
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.addDocuments.tr, style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(AppString.identityProof.tr.replaceAll('*', ''), style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentUploadBox(_identityDocs, _existingIdentityDocUrls, _pickIdentityDoc),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(AppString.medicalDocuments.tr.replaceAll('*', ''), style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentUploadBox(_medicalDocs, _existingMedicalDocUrls, _pickMedicalDoc),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security, color: Color(0xFF1976D2), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppString.securityTip.tr,
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: const Color(0xFF1976D2), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  String _getDocumentDisplayName(String url) {
    if (url.isEmpty) return '';
    try {
      if (url.contains('name=')) {
        final fragmentOrQuery = url.contains('#')
            ? url.split('#').last
            : (url.contains('?') ? url.split('?').last : '');
        final params = Uri.splitQueryString(fragmentOrQuery);
        if (params.containsKey('name') && params['name']!.isNotEmpty) {
          final nameVal = params['name']!;
          try {
            return Uri.decodeComponent(nameVal);
          } catch (_) {
            return nameVal;
          }
        }
      }
    } catch (_) {}
    final rawName = url.split('/').last;
    return rawName.split('#').first.split('?').first;
  }

  Widget _buildDocumentUploadBox(List<File> docs, List<String> existingUrls, VoidCallback onPick) {
    final totalCount = docs.length + existingUrls.length;
    return Column(
      children: [
        if (totalCount == 0)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPick,
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: AppTheme.fieldBorderColor,
                strokeWidth: 2,
                dashPattern: const <double>[6, 4],
                radius: const Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 32),
                    const SizedBox(height: 12),
                    Text(AppString.clickToUpload.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("PNG, JPG, PDF (Max. : 5MB)", style: AppFonts.regularText.copyWith(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          )
        else ...[
          ...List.generate(existingUrls.length, (index) {
            final fileName = _getDocumentDisplayName(existingUrls[index]);
            final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.fieldBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.description_outlined,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppFonts.regularText.copyWith(fontSize: 13, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        existingUrls.removeAt(index);
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
            );
          }),
          ...List.generate(docs.length, (index) {
            final fileName = docs[index].path.split(RegExp(r'[/\\]')).last;
            final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.fieldBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.description_outlined,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppFonts.regularText.copyWith(fontSize: 13, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        docs.removeAt(index);
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
            );
          }),
        ],
        if (totalCount > 0)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.fieldBorderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: onPick,
              child: Text(AppString.addMore.tr, style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ),
          ),
      ],
    );
  }

  Future<String?> _uploadFileToCatbox(File file) async {
    if (!file.existsSync()) return null;
    try {
      final client = http.Client();
      try {
        final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
        request.fields['reqtype'] = 'fileupload';
        request.files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        final responseData = await streamedResponse.stream.bytesToString();
        if (streamedResponse.statusCode == 200) {
          final url = responseData.trim();
          if (url.startsWith('https://files.catbox.moe/')) {
            log("✅ [_uploadFileToCatbox] Upload SUCCESS to Catbox: $url");
            return url;
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      log("⚠️ [_uploadFileToCatbox] Direct Catbox upload exception: $e. Falling back to ProfileController.uploadFile...");
    }

    // Delegate to ProfileController.uploadFile which uses ImgBB (works in India)
    // and falls back to Catbox with proper timeouts and error logging.
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    return await profileController.uploadFile(file);
  }

  Future<void> _submitCampaign() async {
    if (_mobileController.text.trim().isEmpty) {
      showSnackBar("Please enter mobile number.", false);
      return;
    }
    if (_mobileController.text.trim().length != 10) {
      showSnackBar("Please enter a valid 10-digit mobile number.", false);
      return;
    }
    final emailText = _emailController.text.trim();
    if (emailText.isEmpty) {
      showSnackBar("Please enter email address.", false);
      return;
    }
    if (!GetUtils.isEmail(emailText) || !RegExp(r"^[\w\.\-]+@[\w\-]+(\.[a-zA-Z]{2,})+$").hasMatch(emailText)) {
      showSnackBar("Please enter a valid email address.", false);
      return;
    }
    if (_holderNameController.text.trim().isEmpty) {
      showSnackBar("Please enter account holder name.", false);
      return;
    }
    if (_bankNameController.text.trim().isEmpty) {
      showSnackBar("Please enter bank name.", false);
      return;
    }
    if (_accountNumberController.text.trim().isEmpty) {
      showSnackBar("Please enter account number.", false);
      return;
    }
    if (_ifscCodeController.text.trim().isEmpty) {
      showSnackBar("Please enter IFSC code.", false);
      return;
    }

    bool dialogDismissed = false;
    void dismissProgressDialog() {
      if (!dialogDismissed && mounted) {
        dialogDismissed = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.threeRotatingDots(
                    color: AppTheme.primaryDeepBlue,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text("Uploading campaign media & files...", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      List<String> imageUrls = [];
      if (_mainImage != null && _mainImage!.existsSync()) {
        log("Uploading main cover image file: ${_mainImage!.path}");
        final mainUrl = await _uploadFileToCatbox(_mainImage!);
        if (mainUrl != null && mainUrl.trim().isNotEmpty) {
          imageUrls.add(mainUrl.trim());
        }
      } else if (_isEdit && _existingMainImageUrl != null && _existingMainImageUrl!.isNotEmpty) {
        imageUrls.add(_existingMainImageUrl!.trim());
      }

      for (int i = 0; i < _smallImages.length; i++) {
        var f = _smallImages[i];
        if (f != null && f.existsSync()) {
          log("Uploading small image slot $i: ${f.path}");
          final url = await _uploadFileToCatbox(f);
          if (url != null && url.trim().isNotEmpty) {
            imageUrls.add(url.trim());
          }
        }
      }
      if (_isEdit && _existingSmallImageUrls.isNotEmpty) {
        for (var ext in _existingSmallImageUrls) {
          if (ext.trim().isNotEmpty && !imageUrls.contains(ext.trim())) {
            imageUrls.add(ext.trim());
          }
        }
      }

      if (imageUrls.isEmpty) {
        imageUrls.add("https://images.unsplash.com/photo-148852178991-ed7bbaeae773?auto=format&fit=crop&q=80&w=600");
      }

      log("--------------------------------------------------");
      log("📸 CAMPAIGN IMAGES TO BE SENT IN PAYLOAD: $imageUrls");
      log("--------------------------------------------------");
      debugPrint("📸 CAMPAIGN IMAGES TO BE SENT IN PAYLOAD: $imageUrls");

      List<String> identityUrls = [];
      if (_isEdit && _existingIdentityDocUrls.isNotEmpty) {
        for (var u in _existingIdentityDocUrls) {
          final clean = u.split('#').first.trim();
          if (clean.isNotEmpty) {
            final name = _getDocumentDisplayName(u);
            final tagged = name.isNotEmpty
                ? '$clean#type=identity&name=${Uri.encodeComponent(name)}'
                : '$clean#type=identity';
            if (!identityUrls.contains(tagged)) {
              identityUrls.add(tagged);
            }
          }
        }
      }
      for (var f in _identityDocs) {
        final url = await _uploadFileToCatbox(f);
        if (url != null && url.trim().isNotEmpty) {
          final clean = url.trim().split('#').first.trim();
          if (clean.isNotEmpty) {
            final name = f.path.split(RegExp(r'[/\\]')).last;
            final tagged = name.isNotEmpty
                ? '$clean#type=identity&name=${Uri.encodeComponent(name)}'
                : '$clean#type=identity';
            if (!identityUrls.contains(tagged)) {
              identityUrls.add(tagged);
            }
          }
        }
      }

      List<String> medicalUrls = [];
      if (_isEdit && _existingMedicalDocUrls.isNotEmpty) {
        for (var u in _existingMedicalDocUrls) {
          final clean = u.split('#').first.trim();
          if (clean.isNotEmpty) {
            final name = _getDocumentDisplayName(u);
            final tagged = name.isNotEmpty
                ? '$clean#type=medical&name=${Uri.encodeComponent(name)}'
                : '$clean#type=medical';
            if (!medicalUrls.contains(tagged)) {
              medicalUrls.add(tagged);
            }
          }
        }
      }
      for (var f in _medicalDocs) {
        final url = await _uploadFileToCatbox(f);
        if (url != null && url.trim().isNotEmpty) {
          final clean = url.trim().split('#').first.trim();
          if (clean.isNotEmpty) {
            final name = f.path.split(RegExp(r'[/\\]')).last;
            final tagged = name.isNotEmpty
                ? '$clean#type=medical&name=${Uri.encodeComponent(name)}'
                : '$clean#type=medical';
            if (!medicalUrls.contains(tagged)) {
              medicalUrls.add(tagged);
            }
          }
        }
      }

      List<String> documentUrls = [...identityUrls, ...medicalUrls];
      if (documentUrls.isEmpty) {
        documentUrls.add("https://s3.amazonaws.com/divine-docs/ngo_registration_pratham.pdf#type=medical");
      }

      log("📄 CAMPAIGN IDENTITY DOCUMENTS TO BE SENT: $identityUrls");
      log("📄 CAMPAIGN MEDICAL DOCUMENTS TO BE SENT: $medicalUrls");
      log("📄 CAMPAIGN ALL DOCUMENTS TO BE SENT IN PAYLOAD: $documentUrls");
      debugPrint("📄 CAMPAIGN IDENTITY DOCUMENTS TO BE SENT: $identityUrls");
      debugPrint("📄 CAMPAIGN MEDICAL DOCUMENTS TO BE SENT: $medicalUrls");
      debugPrint("📄 CAMPAIGN ALL DOCUMENTS TO BE SENT IN PAYLOAD: $documentUrls");

      dismissProgressDialog();

      final String endDateStr = _selectedDateTime != null 
          ? _selectedDateTime!.toUtc().toIso8601String() 
          : DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String();

      // EDIT CAMPAIGN FLOW (PUT)
      if (_isEdit && _editCampaignId != null && _editCampaignId!.isNotEmpty) {
        final payload = {
          "title": _titleController.text.trim(),
          "category": _selectedCategory ?? "Medical",
          "description": _storyController.document.toPlainText().trim(),
          "goal": double.tryParse(_amountController.text.trim()) ?? 75000,
          "mobile": _mobileController.text.trim(),
          "email": _emailController.text.trim(),
          "imageUrl": imageUrls.isNotEmpty ? imageUrls.first : (_existingMainImageUrl ?? "https://files.catbox.moe/q4i0t0.jpg"),
          "images": imageUrls,
          "oneTimeOrMonthly": "One-Time",
          "endDate": endDateStr,
          "status": _existingStatus ?? "Live",
          "video": _existingVideo ?? "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          "documents": documentUrls,
          "verificationDocs": identityUrls,
          "identityDocs": identityUrls,
          "medicalDocs": medicalUrls,
          "bankDetails": {
            "accountNumber": _accountNumberController.text.trim(),
            "ifscCode": _ifscCodeController.text.trim(),
            "bankName": _bankNameController.text.trim(),
            "holderName": _holderNameController.text.trim(),
          }
        };

        if (!mounted) return;
        final response = await Repositories().putApi(
          context: context,
          url: ApiUrls.getCampaignDetailsUrl(_editCampaignId!),
          mapData: payload,
          showResponse: true,
        );

        dismissProgressDialog();

        if (response != null) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response);
          if (jsonResponse['status'] == true ||
              jsonResponse['status'] == 'Live' ||
              jsonResponse['status'] == 'success' ||
              jsonResponse['data'] != null) {
            _clearFields();
            if (Get.isRegistered<MyCampaignsController>()) {
              Get.find<MyCampaignsController>().fetchMyCampaigns();
            }
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().fetchHomeData(forceRefresh: true);
            }
            if (Get.isRegistered<ActiveCampaignsController>()) {
              Get.find<ActiveCampaignsController>().fetchActiveCampaigns();
            }

            bool poppedToMyCampaigns = false;
            Get.until((route) {
              if (route.settings.name == MyRouters.myCampaignsScreen) {
                poppedToMyCampaigns = true;
                return true;
              }
              return route.isFirst;
            });
            if (!poppedToMyCampaigns) {
              Get.offNamed(MyRouters.myCampaignsScreen);
            }

            showSnackBar(jsonResponse['message'] ?? "Campaign updated successfully", true);
          } else {
            showSnackBar(jsonResponse['message'] ?? "Failed to update campaign.", false);
          }
        } else {
          showSnackBar("No response from server.", false);
        }
        return;
      }

      // RAISE CAMPAIGN FLOW (POST)
      final payload = {
        "title": _titleController.text.trim(),
        "category": _selectedCategory ?? "Education Aid",
        "goal": double.tryParse(_amountController.text.trim()) ?? 75000,
        "description": _storyController.document.toPlainText().trim(),
        "oneTimeOrMonthly": "One-Time",
        "endDate": endDateStr,
        "mobile": _mobileController.text.trim(),
        "email": _emailController.text.trim(),
        "images": imageUrls,
        "video": "https://www.w3schools.com/html/mov_bbb.mp4",
        "documents": documentUrls,
        "verificationDocs": identityUrls,
        "identityDocs": identityUrls,
        "medicalDocs": medicalUrls,
        "is_verified": false,
        "bankDetails": {
          "holderName": _holderNameController.text.trim(),
          "accountNumber": _accountNumberController.text.trim(),
          "bankName": _bankNameController.text.trim(),
          "ifscCode": _ifscCodeController.text.trim(),
        }
      };

      if (!mounted) return;
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.donorCampaignsUrl,
        mapData: payload,
        showResponse: true,
      );

      dismissProgressDialog();

      if (response != null) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true || jsonResponse['message'] == 'Campaign submitted for review successfully. It will be published upon admin approval.') {
          _clearFields();

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData(forceRefresh: true);
          }
          if (Get.isRegistered<ActiveCampaignsController>()) {
            Get.find<ActiveCampaignsController>().fetchActiveCampaigns();
          }
          if (Get.isRegistered<MyCampaignsController>()) {
            Get.find<MyCampaignsController>().fetchMyCampaigns();
          }

          Get.offAllNamed(MyRouters.campaignVerificationScreen);
        } else {
          showSnackBar(jsonResponse['message'] ?? "Failed to create campaign.", false);
        }
      } else {
        showSnackBar("No response from server.", false);
      }
    } catch (e) {
      dismissProgressDialog();
      showSnackBar("An unexpected error occurred: ${e.toString()}", false);
    }
  }

  Widget _buildBankDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.stepBankDetails.tr, style: AppFonts.titleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 24),
          _buildTextField(AppString.accountHolder.tr, AppString.enterFullName.tr, controller: _holderNameController),
          const SizedBox(height: 16),
          _buildTextField(AppString.bankName.tr, AppString.enterBankName.tr, controller: _bankNameController),
          const SizedBox(height: 16),
          _buildTextField(AppString.accountNumber.tr, AppString.enterAccountNumber.tr, controller: _accountNumberController),
          const SizedBox(height: 16),
          _buildTextField(AppString.ifscCode.tr, AppString.enterIfscCode.tr, controller: _ifscCodeController),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.fieldBorderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) {
                      showSnackBar("Please enter a campaign title.", false);
                      return;
                    }
                    if (_selectedCategory == null) {
                      showSnackBar("Please select a campaign category.", false);
                      return;
                    }
                    if (_amountController.text.trim().isEmpty) {
                      showSnackBar("Please enter a target amount.", false);
                      return;
                    }
                    if (_amountController.text.trim().length > 10) {
                      showSnackBar("Target amount cannot be more than 10 digits", false);
                      return;
                    }
                    if (_dateController.text.trim().isEmpty) {
                      showSnackBar("Please select an end date.", false);
                      return;
                    }
                    if (_mobileController.text.trim().isEmpty) {
                      showSnackBar("Please enter mobile number.", false);
                      return;
                    }
                    if (_mobileController.text.trim().length != 10) {
                      showSnackBar("Please enter a valid 10-digit mobile number.", false);
                      return;
                    }
                    final emailText = _emailController.text.trim();
                    if (emailText.isEmpty) {
                      showSnackBar("Please enter email address.", false);
                      return;
                    }
                    if (!GetUtils.isEmail(emailText) || !RegExp(r"^[\w\.\-]+@[\w\-]+(\.[a-zA-Z]{2,})+$").hasMatch(emailText)) {
                      showSnackBar("Please enter a valid email address.", false);
                      return;
                    }
                    if (_storyController.document.toPlainText().trim().isEmpty) {
                      showSnackBar("Please write a campaign story.", false);
                      return;
                    }
                    if (_mainImage == null && (_existingMainImageUrl == null || _existingMainImageUrl!.isEmpty)) {
                      showSnackBar("Please upload a cover image.", false);
                      return;
                    }
                    if (!_isEdit && _identityDocs.isEmpty && _existingIdentityDocUrls.isEmpty) {
                      showSnackBar("Please upload identity proof.", false);
                      return;
                    }
                    if (_medicalDocs.isEmpty && _existingMedicalDocUrls.isEmpty) {
                      showSnackBar("Please upload medical documents.", false);
                      return;
                    }
                    if (_holderNameController.text.trim().isEmpty) {
                      showSnackBar("Please enter account holder name.", false);
                      return;
                    }
                    if (_bankNameController.text.trim().isEmpty) {
                      showSnackBar("Please enter bank name.", false);
                      return;
                    }
                    if (_accountNumberController.text.trim().isEmpty) {
                      showSnackBar("Please enter account number.", false);
                      return;
                    }
                    if (_ifscCodeController.text.trim().isEmpty) {
                      showSnackBar("Please enter IFSC code.", false);
                      return;
                    }

                    Get.toNamed(
                      MyRouters.raiseCampaignPreviewScreen,
                      arguments: {
                        "title": _titleController.text.trim(),
                        "category": _selectedCategory,
                        "goal": _amountController.text.trim(),
                        "description": _storyController.document.toPlainText().trim(),
                        "endDate": _selectedDateTime,
                        "mainImage": _mainImage,
                        "smallImages": _smallImages.where((f) => f != null).cast<File>().toList(),
                        "identityDocs": _identityDocs,
                        "medicalDocs": _medicalDocs,
                        "isEdit": _isEdit,
                        "networkImages": [
                          if (_mainImage == null && _existingMainImageUrl != null && _existingMainImageUrl!.isNotEmpty)
                            _existingMainImageUrl!,
                          ..._existingSmallImageUrls.where((u) => u.isNotEmpty),
                        ],
                        "onSubmit": _submitCampaign,
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, color: Colors.black54, size: 18),
                      const SizedBox(width: 8),
                      Text(AppString.preview.tr, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitCampaign,
                  child: Text(_isEdit ? "Update" : AppString.raiseAction.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mobile Number", style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  countryListTheme: CountryListThemeData(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    inputDecoration: InputDecoration(
                      hintText: 'Search country',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.fieldBorderColor),
                      ),
                    ),
                  ),
                  onSelect: (Country country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                );
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        color: AppTheme.blackColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textGrey400),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: "Enter Mobile Number",
                  hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {Widget? prefixIcon, Widget? suffixIcon, TextEditingController? controller, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
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
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    final String effectiveHint = _isLoadingCategories ? "Loading categories..." : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.fieldBorderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(selectedValue) ? selectedValue : null,
              hint: Text(effectiveHint, style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14)),
              icon: _isLoadingCategories
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: AppFonts.regularText.copyWith(color: Colors.black87, fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryDeepBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: _nextStep,
        child: Text(AppString.next.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double dashWidth = 4;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
