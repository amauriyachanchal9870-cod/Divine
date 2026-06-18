import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Routes/my_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = true;
  bool smsEnabled = false;
  bool emailEnabled = true;

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
              _buildSwitchTile(Icons.notifications_none, AppString.pushNotification.tr, pushEnabled, (val) {
                setState(() => pushEnabled = val);
              }),
              _buildSwitchTile(Icons.message_outlined, AppString.smsNotification.tr, smsEnabled, (val) {
                setState(() => smsEnabled = val);
              }),
              _buildSwitchTile(Icons.email_outlined, AppString.emailNotification.tr, emailEnabled, (val) {
                setState(() => emailEnabled = val);
              }),
              const SizedBox(height: 32),
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
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
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
    );
  }

  Widget _buildDeactivateTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.person_off_outlined, color: Colors.black87, size: 22),
        title: Text(AppString.inactiveAccount.tr, style: AppFonts.mediumText.copyWith(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Get.toNamed(MyRouters.inactiveAccountScreen),
      ),
    );
  }
}
