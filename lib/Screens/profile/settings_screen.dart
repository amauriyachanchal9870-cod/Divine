import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

import '../../Controller/profile_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileController profileController =
      Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

  bool pushEnabled = true;
  bool smsEnabled = false;
  bool emailEnabled = true;

  @override
  void initState() {
    super.initState();
    _initPushNotificationState();
  }

  void _initPushNotificationState() {
    if (profileController.profileData.value?.pushNotification != null) {
      pushEnabled = profileController.profileData.value!.pushNotification!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile(context, forceRefresh: true).then((_) {
        if (mounted && profileController.profileData.value?.pushNotification != null) {
          setState(() {
            pushEnabled = profileController.profileData.value!.pushNotification!;
          });
        }
      });
    });
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
        title: Text(AppString.accountSettings.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(AppString.notificationLabel.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
              const SizedBox(height: 16),
              _buildSwitchTile(Icons.notifications_none, AppString.pushNotification.tr, pushEnabled, (val) async {
                setState(() => pushEnabled = val);
                
                Map<String, dynamic> updateMap = {};
                if (profileController.profileData.value != null) {
                  final currentData = profileController.profileData.value!.toJson();
                  currentData.forEach((key, value) {
                    if (value != null) {
                      updateMap[key] = value;
                    }
                  });
                }
                updateMap['pushNotification'] = val;

                await profileController.updateProfile(
                  context: context,
                  mapData: updateMap,
                );
              }),
              // _buildSwitchTile(Icons.message_outlined, AppString.smsNotification.tr, smsEnabled, (val) {
              //   setState(() => smsEnabled = val);
              // }),
              // _buildSwitchTile(Icons.email_outlined, AppString.emailNotification.tr, emailEnabled, (val) {
              //   setState(() => emailEnabled = val);
              // }),
              const SizedBox(height: 16),
              Text(AppString.accountAction.tr, style: AppFonts.semiBoldText.copyWith(fontSize: 16)),
              const SizedBox(height: 16),
              _buildDeactivateTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: Colors.black87, size: 22),
          title: Text(title, style: AppFonts.mediumText.copyWith(fontSize: 14)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.progressGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildDeactivateTile() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          title: Text(AppString.deleteAccount.tr, style: AppFonts.mediumText.copyWith(fontSize: 14, color: Colors.red)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () => Get.toNamed(MyRouters.inactiveAccountScreen),
        ),
      ),
    );
  }
}
