import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import '../../Routes/my_routes.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedCategory;

  final List<Map<String, dynamic>> _faqItems = [
    {
      "question": "Is there a free trial available?",
      "answer": "Yes, you can try us for free for 30 days. If you want, we'll provide you with a free, personalized 30-minute onboarding call to get you up and running as soon as possible.",
      "isExpanded": true,
    },
    {
      "question": "Can I change my plan later?",
      "answer": "Yes, you can upgrade, downgrade, or change your plan at any time from your account settings.",
      "isExpanded": false,
    },
    {
      "question": "What is your cancellation policy?",
      "answer": "You can cancel your subscription at any time. Your subscription will remain active until the end of the current billing period.",
      "isExpanded": false,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFaqItems {
    if (_searchQuery.trim().isEmpty) {
      return _faqItems;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _faqItems.where((item) {
      final question = (item['question'] as String? ?? '').toLowerCase();
      final answer = (item['answer'] as String? ?? '').toLowerCase();
      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.howCanWeHelpYou.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("All Questions", style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                if (_filteredFaqItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Center(
                      child: Text(
                        "No questions found.",
                        style: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ..._filteredFaqItems.map((item) => _buildFaqItem(item)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "View Tickets",
                        style: AppFonts.regularText.copyWith(
                          fontSize: 12,
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.searchBarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: InkWell(
                        onTap: () => Get.toNamed(MyRouters.myTicketsScreen),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppString.myTickets.tr,
                                  style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.black),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDeepBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => _showRaiseTicketSheet(context),
                        child: Text(
                          AppString.raiseTicket.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: "Search questions...",
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> item) {
    final bool isExpanded = item['isExpanded'] ?? false;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.fieldBorderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(
              item['question'],
              style: AppFonts.mediumText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: Colors.grey,
              size: 20,
            ),
            onTap: () {
              setState(() {
                item['isExpanded'] = !isExpanded;
              });
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Text(
                item['answer'],
                style: AppFonts.regularText.copyWith(
                  fontSize: 13,
                  color: AppTheme.subTextColor,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }


  void _showRaiseTicketSheet(BuildContext context) {
    _messageController.clear();
    _selectedCategory = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppString.raiseTicket.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.searchBarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          hint: Text(AppString.selectCategory.tr, style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500)),
                          items: <String>['Donation Issue', 'Technical Bug', 'Account Query', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setStateSheet(() {
                              _selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.searchBarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppString.writeFeedback.tr,
                          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
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
                        onPressed: () async {
                          if (_selectedCategory == null) {
                            Get.snackbar(
                              "Required",
                              "Please select a category",
                              backgroundColor: AppTheme.redColor,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (_messageController.text.trim().isEmpty) {
                            Get.snackbar(
                              "Required",
                              "Please write your feedback/message",
                              backgroundColor: AppTheme.redColor,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          Get.back(); // Close bottom sheet
                          
                          bool success = await _profileController.raiseSupportTicket(
                            context: context,
                            subject: _selectedCategory!,
                            message: _messageController.text.trim(),
                          );

                          if (success) {
                            Get.snackbar(
                              "Success",
                              "Support ticket submitted successfully",
                              backgroundColor: AppTheme.greenColor,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          AppString.submit.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
