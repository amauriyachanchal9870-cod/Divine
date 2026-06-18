import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
        title: Text(AppString.helpSupport.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
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
                  child: Text(AppString.faq.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                _buildFaqItem("Is the 100% tax relief available?"),
                _buildFaqItem("Can I change my donation?"),
                _buildFaqItem("What is your cancellation policy?"),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppString.myTickets.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmptyTicketsState(),
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
                child: SizedBox(
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
        decoration: InputDecoration(
          hintText: AppString.howCanWeHelpYou.tr,
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.fieldBorderColor)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(question, style: AppFonts.mediumText.copyWith(fontSize: 14)),
        trailing: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmptyTicketsState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.support_agent, size: 80, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            AppString.youDoNotHaveTickets.tr,
            style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showRaiseTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                      hint: Text(AppString.selectCategory.tr, style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500)),
                      items: <String>['Donation Issue', 'Technical Bug', 'Account Query', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {},
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
                    onPressed: () => Get.back(),
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
  }
}
