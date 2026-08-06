import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import '../../Repo/common_repo.dart';
import '../../Utilities/api_constant.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Utilities/helper.dart';
import '../../Controller/home_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchCampaignCategories();
    _storyController.addListener(() {
      int length = _storyController.document.toPlainText().length - 1;
      _storyLengthNotifier.value = length > 0 ? length : 0;
    });
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
    _holderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _storyLengthNotifier.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _amountController.clear();
      _dateController.clear();
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
      _currentStep = 0;
      _storyController.document = quill.Document();
    });
    _pageController.jumpToPage(0);
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
                    allowedExtensions: ['pdf'],
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
      final double targetAmt = double.tryParse(_amountController.text.trim()) ?? 0;
      if (targetAmt > 100000000) {
        showSnackBar("Target amount cannot be more than 100000000", false);
        return;
      }
      if (_dateController.text.trim().isEmpty) {
        showSnackBar("Please select an end date.", false);
        return;
      }
      if (_storyController.document.toPlainText().trim().isEmpty) {
        showSnackBar("Please write a campaign story.", false);
        return;
      }
    } else if (_currentStep == 1) {
      if (_mainImage == null) {
        showSnackBar("Please upload a cover image.", false);
        return;
      }
    } else if (_currentStep == 2) {
      if (_identityDocs.isEmpty) {
        showSnackBar("Please upload identity proof.", false);
        return;
      }
      if (_medicalDocs.isEmpty) {
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
            : null,
        title: Text(AppString.raiseACampaign.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
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
          _buildTextField(AppString.targetAmount.tr, AppString.enterAmount.tr, prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: Colors.grey), controller: _amountController),
          const SizedBox(height: 16),
          _buildTextField(AppString.endDate.tr, AppString.selectDate.tr, suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey), controller: _dateController, readOnly: true, onTap: () => _selectDate(context)),
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: Colors.grey, size: 28),
                                const SizedBox(height: 8),
                                Text(AppString.mainPhoto.tr, style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
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
    bool hasImage = _smallImages[index] != null;
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
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_smallImages[index]!, fit: BoxFit.cover),
                )
              : const Center(
                  child: Icon(Icons.add, color: Colors.grey, size: 24),
                ),
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
          _buildDocumentUploadBox(_identityDocs, _pickIdentityDoc),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(AppString.medicalDocuments.tr.replaceAll('*', ''), style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
              const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentUploadBox(_medicalDocs, _pickMedicalDoc),
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

  Widget _buildDocumentUploadBox(List<File> docs, VoidCallback onPick) {
    return Column(
      children: [
        if (docs.isEmpty)
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
        else
          Column(
            children: List.generate(docs.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.fieldBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.blue, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        docs[index].path.split('/').last,
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
          ),
        if (docs.isNotEmpty)
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
    try {
      final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
      request.fields['reqtype'] = 'fileupload';
      request.files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final url = responseData.trim();
        debugPrint("Uploaded file URL: $url");
        return url;
      }
    } catch (e) {
      debugPrint("Error uploading file to Catbox: $e");
    }
    return null;
  }

  Future<void> _submitCampaign() async {
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
      if (_mainImage != null) {
        final mainUrl = await _uploadFileToCatbox(_mainImage!);
        if (mainUrl != null) imageUrls.add(mainUrl);
      }
      for (var f in _smallImages) {
        if (f != null) {
          final url = await _uploadFileToCatbox(f);
          if (url != null) imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) {
        imageUrls.add("https://images.unsplash.com/photo-148852178991-ed7bbaeae773?auto=format&fit=crop&q=80&w=600");
      }

      List<String> documentUrls = [];
      for (var f in _identityDocs) {
        final url = await _uploadFileToCatbox(f);
        if (url != null) documentUrls.add(url);
      }
      for (var f in _medicalDocs) {
        final url = await _uploadFileToCatbox(f);
        if (url != null) documentUrls.add(url);
      }

      if (documentUrls.isEmpty) {
        documentUrls.add("https://s3.amazonaws.com/divine-docs/ngo_registration_pratham.pdf");
      }

      if (mounted) Navigator.of(context).pop();

      final String endDateStr = _selectedDateTime != null 
          ? _selectedDateTime!.toUtc().toIso8601String() 
          : DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String();

      final payload = {
        "title": _titleController.text.trim(),
        "category": _selectedCategory ?? "Education Aid",
        "goal": double.tryParse(_amountController.text.trim()) ?? 75000,
        "description": _storyController.document.toPlainText().trim(),
        "oneTimeOrMonthly": "One-Time",
        "endDate": endDateStr,
        "images": imageUrls,
        "video": "https://www.w3schools.com/html/mov_bbb.mp4",
        "documents": documentUrls,
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

      if (response != null) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          showSnackBar("Campaign created successfully!", true);
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData();
          }
          _clearFields();
          mainNavKey.currentState?.changeTab(0);
          Get.until((route) => route.settings.name == MyRouters.mainNav || route.isFirst);
        } else {
          showSnackBar(jsonResponse['message'] ?? "Failed to create campaign.", false);
        }
      } else {
        showSnackBar("No response from server.", false);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
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
                    final double targetAmtSubmit = double.tryParse(_amountController.text.trim()) ?? 0;
                    if (targetAmtSubmit > 100000000) {
                      showSnackBar("Target amount cannot be more than 100000000", false);
                      return;
                    }
                    if (_dateController.text.trim().isEmpty) {
                      showSnackBar("Please select an end date.", false);
                      return;
                    }
                    if (_storyController.document.toPlainText().trim().isEmpty) {
                      showSnackBar("Please write a campaign story.", false);
                      return;
                    }
                    if (_mainImage == null) {
                      showSnackBar("Please upload a cover image.", false);
                      return;
                    }
                    if (_identityDocs.isEmpty) {
                      showSnackBar("Please upload identity proof.", false);
                      return;
                    }
                    if (_medicalDocs.isEmpty) {
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
                  child: Text(AppString.raiseAction.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {Widget? prefixIcon, Widget? suffixIcon, TextEditingController? controller, bool readOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
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
