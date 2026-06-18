import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppString.search.tr,
          style: AppFonts.titleStyle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.fieldBorderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppString.searchForCampaigns.tr,
                      hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    style: AppFonts.regularText.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppString.recentSearches.tr,
              style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildRecentSearchItem("Rural education Initiative"),
                _buildRecentSearchItem("Save the Children"),
                _buildRecentSearchItem("Green Earth Foundation"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String title) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey, size: 20),
      title: Text(title, style: AppFonts.regularText.copyWith(fontSize: 14)),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 16),
        onPressed: () {},
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
    );
  }
}
