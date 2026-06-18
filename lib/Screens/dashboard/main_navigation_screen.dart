import 'package:divine_foundation/Screens/dashboard/raise_campaign_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_assets.dart';
import 'home_screen.dart';
import 'donate_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DonateScreen(),
    const RaiseCampaignWizardScreen(), // Placeholder
    const WalletScreen(),
    const ProfileScreen(),
  ];

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, AppAssets.home, AppAssets.homeFill, AppString.home.tr),
              _buildNavItem(1, AppAssets.donate, AppAssets.donateFill, AppString.donate.tr),
              _buildNavItem(2, AppAssets.raise, AppAssets.raiseFill, AppString.raise.tr),
              _buildNavItem(3, AppAssets.wallet, AppAssets.walletFill, AppString.wallet.tr),
              _buildNavItem(4, AppAssets.profile, AppAssets.profile, AppString.profile.tr, isProfile: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String activeIconPath, String label, {bool isProfile = false}) {
    bool isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryDeepBlue.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isProfile
                  ? ClipOval(
                      child: Image.asset(
                        iconPath,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      isActive ? activeIconPath : iconPath,
                      height: 24,
                      width: 24,
                      color: isActive ? AppTheme.primaryDeepBlue : AppTheme.textGrey400,
                    ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppTheme.primaryDeepBlue : AppTheme.textGrey400,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
