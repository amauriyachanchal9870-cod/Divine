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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../Controller/profile_controller.dart';
import '../../Controller/home_controller.dart';
import '../../Utilities/helper.dart';

final GlobalKey<MainNavigationScreenState> mainNavKey = GlobalKey<MainNavigationScreenState>();

class MainNavigationScreen extends StatefulWidget {
  MainNavigationScreen({Key? key}) : super(key: key ?? (mainNavKey.currentState == null ? mainNavKey : null));

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final Set<int> _loadedTabs;
  final ProfileController _profileController = Get.put(ProfileController());
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is int) {
      _selectedIndex = Get.arguments as int;
    }
    _loadedTabs = {_selectedIndex};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_profileController.profileData.value == null) {
        _profileController.fetchProfile(context);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const DonateScreen(),
    const RaiseCampaignWizardScreen(), // Placeholder
    const WalletScreen(),
    const ProfileScreen(),
  ];

  bool get _isCorporate {
    final role = (_profileController.profileData.value?.role ?? '').toLowerCase();
    return role == 'corporate';
  }

  void changeTab(int index) {
    if (index == 2 && _isCorporate) {
      showSnackBar("Corporate users cannot raise campaigns", false);
      return;
    }
    setState(() {
      _selectedIndex = index;
      _loadedTabs.add(index);
    });
  }

  void _onItemTapped(int index) {
    if (index == 2 && _isCorporate) {
      showSnackBar("Corporate users cannot raise campaigns", false);
      return;
    }
    if (Get.isRegistered<HomeController>()) {
      if (Get.find<HomeController>().isLoading.value) return;
    }
    changeTab(index);
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_selectedIndex != 0) {
          changeTab(0);
        } else {
          final now = DateTime.now();
          if (_lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = now;
            showSnackBar("Press again to exit", false);
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(_screens.length, (i) {
            if (_loadedTabs.contains(i)) {
              return _screens[i];
            }
            return const SizedBox.shrink();
          }),
        ),
        bottomNavigationBar: Obx(() {
          // Touch profileData so Obx subscribes to role changes
          if (_profileController.profileData.value?.role != null) {}
          if (_selectedIndex == 0 && Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            if (homeController.isLoading.value && homeController.homeData.value == null) {
              return const SizedBox.shrink();
            }
          }
          return SafeArea(
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
                  _buildNavItem(4, AppAssets.profile, AppAssets.profile, AppString.profile.tr, isProfile: true, profileController: _profileController),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String activeIconPath, String label, {bool isProfile = false, ProfileController? profileController}) {
    bool isActive = _selectedIndex == index;
    bool isDisabled = (index == 2 && _isCorporate);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: isDisabled ? 0.35 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: (isActive && !isDisabled) ? AppTheme.primaryDeepBlue.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isProfile
                  ? Obx(() {
                      final profile = profileController?.profileData.value;
                      String photoUrl = '';
                      if (profile != null) {
                        if (profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty && profile.profilePhoto != 'null') {
                          photoUrl = profile.profilePhoto!;
                        } else if (profile.logo != null && profile.logo!.isNotEmpty && profile.logo != 'null') {
                          photoUrl = profile.logo!;
                        }
                      }
                      if (photoUrl.isNotEmpty) {
                        return Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? AppTheme.primaryDeepBlue : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Image.asset(
                                AppAssets.appLogo,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ClipOval(
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    })
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
    ),
    );
  }
}
