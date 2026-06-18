import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? titleText;
  final bool showBackButton;
  final bool centerTitle;
  final Widget? sufFix;
  final Widget? preFix;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.titleText,
    this.showBackButton = true,
    this.sufFix,
    this.preFix,
    this.onTap,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final themeChangeController = Get.put(AppTheme());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (themeChangeController.refreshInt.value >= 0) {}
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: widget.backgroundColor ?? AppTheme.backgroundWhiteColor,
        elevation: widget.elevation ?? 0,
        centerTitle: widget.centerTitle,
        surfaceTintColor: AppTheme.primaryColor,

        leading: widget.showBackButton
            ? GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap ?? () => Get.back(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.preFix ??
                  const Center(
                    child: Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
            ),
          ),
        )
            : null,

        title: Text(
          widget.titleText ?? "",
          style: GoogleFonts.poppins(
            color: AppTheme.txtColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),

        actions: [
          if (widget.sufFix != null) widget.sufFix!,
        ],
      );
    });
  }
}
