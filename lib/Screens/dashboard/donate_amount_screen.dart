import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Widget/shimmer_widget.dart';
import '../../Model/campaign_details_model.dart';
import '../../Model/home_model.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';
import '../../Utilities/helper.dart';

class DonateAmountScreen extends StatefulWidget {
  const DonateAmountScreen({super.key});

  @override
  State<DonateAmountScreen> createState() => _DonateAmountScreenState();
}

class _DonateAmountScreenState extends State<DonateAmountScreen> {
  int _selectedAmountIndex = 0;
  final List<int> _presetAmounts = [200, 500, 1000, 2000, 5000];
  final TextEditingController _customAmountController = TextEditingController();

  int get _currentAmount {
    if (_selectedAmountIndex == -1) {
      return int.tryParse(_customAmountController.text) ?? 0;
    }
    return _presetAmounts[_selectedAmountIndex];
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
        title: Text(AppString.donateNow.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCampaignSnippet(),
                  const SizedBox(height: 24),
                  Text(AppString.chooseDonationAmount.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildAmountRow(),
                  const SizedBox(height: 24),
                  Text(AppString.customAmount.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildCustomAmountField(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCampaignSnippet() {
    final args = Get.arguments;
    
    String? imageUrl;
    String? title;
    String? raised;
    String? goal;
    
    if (args is CampaignDetailsData) {
      imageUrl = args.imageUrl;
      title = args.title;
      raised = args.formattedRaised;
      goal = args.formattedGoal;
    } else if (args is HomeCampaign) {
      imageUrl = args.imageUrl;
      title = args.title;
      raised = args.formattedRaised;
      goal = args.formattedGoal;
    } else if (args is Map) {
      imageUrl = args['logoUrl'];
      title = "Donation to ${args['name']}";
      raised = "₹0";
      goal = "Any";
    }
    
    // Fallback if no campaign passed in arguments
    imageUrl ??= '';
    title ??= 'Rural education Initiative';
    raised ??= '₹54K';
    goal ??= '₹75K';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => const ShimmerWidget(height: 60, width: 80),
                    errorWidget: (ctx, url, err) => Image.asset(AppAssets.campaignImage, width: 80, height: 60, fit: BoxFit.cover),
                  )
                : Image.asset(
                    AppAssets.campaignImage,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.semiBoldText.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.progressGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("$raised raised", style: AppFonts.semiBoldText.copyWith(fontSize: 10, color: AppTheme.progressGreen)),
                    ),
                    const Spacer(),
                    Text("of $goal", style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _presetAmounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedAmountIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAmountIndex = index;
                _customAmountController.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryDeepBlue : Colors.white,
                border: Border.all(color: isSelected ? AppTheme.primaryDeepBlue : AppTheme.fieldBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "₹ ${_presetAmounts[index]}",
                style: AppFonts.semiBoldText.copyWith(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.searchBarBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.fieldBorderColor),
      ),
      child: TextField(
        controller: _customAmountController,
        keyboardType: TextInputType.number,
        onChanged: (val) {
          if (val.isNotEmpty) {
            setState(() {
              _selectedAmountIndex = -1;
            });
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: Colors.black54),
          hintText: AppString.enterYourAmount.tr,
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final args = Get.arguments;
    String? campaignId;
    bool isNgo = false;
    if (args is CampaignDetailsData) {
      campaignId = args.sId;
    } else if (args is HomeCampaign) {
      campaignId = args.sId;
    } else if (args is Map) {
      campaignId = args['id'];
      isNgo = args['isNgo'] ?? false;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              // if (_currentAmount < 50) {
              //   showSnackBar("Amount should be more than 50rs", false);
              //   return;
              // }
              if (_currentAmount <= 0) {
                showSnackBar("Please enter a valid donation amount", false);
                return;
              }
              if (_currentAmount >= 10000000) {
                showSnackBar("Amount should be less than 10000000rs", false);
                return;
              }

              Get.toNamed(
                MyRouters.paymentMethodScreen,
                arguments: {
                  'amount': _currentAmount.toString(),
                  'campaignId': campaignId ?? '',
                  'isNgo': isNgo,
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppString.proceedToPay.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("₹ $_currentAmount", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
