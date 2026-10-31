import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Routes/my_routes.dart';
import '../Utilities/app_theme.dart';
import '../Utilities/custom_appbar.dart';

class ComingSoonScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final bool showAppBar;

  const ComingSoonScreen({
    super.key,
    this.title,
    this.subtitle,
    this.showAppBar = true,
  });

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _screenTitle {
    if (widget.title != null && widget.title!.trim().isNotEmpty) {
      return widget.title!.trim();
    }
    final args = Get.arguments;
    if (args is Map && args['title'] != null && args['title'].toString().trim().isNotEmpty) {
      return args['title'].toString().trim();
    }
    return "Coming Soon";
  }

  String get _subtitleText {
    if (widget.subtitle != null && widget.subtitle!.trim().isNotEmpty) {
      return widget.subtitle!.trim();
    }
    final args = Get.arguments;
    if (args is Map && args['subtitle'] != null && args['subtitle'].toString().trim().isNotEmpty) {
      return args['subtitle'].toString().trim();
    }
    return "We are working hard to craft this feature for you. Stay tuned for exciting updates!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: widget.showAppBar
          ? CustomAppBar(
              titleText: _screenTitle,
              showBackButton: true,
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightCyanBackground.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.buttonColorGray.withValues(alpha: 0.6),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Floating animated icon card
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final floatOffset = math.sin(_controller.value * 2 * math.pi) * 8.0;
                        return Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightCyanBackground,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.buttonColor.withValues(alpha: 0.18),
                              blurRadius: 28,
                              spreadRadius: 6,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.buttonColor,
                                  AppTheme.primaryDeepBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Badge: STAY TUNED
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.badgebackgroung,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.badgeborder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.buttonColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "STAY TUNED",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDeepBlue,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Text "Coming Soon"
                    AnimatedComingSoonText(controller: _controller),

                    const SizedBox(height: 16),

                    // Subtitle description
                    Text(
                      _subtitleText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.subTextColor,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Action Button to Go Back
                    SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Get.back();
                          } else {
                            Get.offAllNamed(MyRouters.mainNav);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          "Go Back",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedComingSoonText extends StatelessWidget {
  final AnimationController controller;

  const AnimatedComingSoonText({
    super.key,
    required this.controller,
  });

  static const String _text = "Coming Soon";

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Letters with staggered wave animation & color shift
            for (int i = 0; i < _text.length; i++) ...[
              _buildLetter(i, _text[i], progress),
            ],
            const SizedBox(width: 4),
            // Animated Bouncing Dots
            _buildDots(progress),
          ],
        );
      },
    );
  }

  Widget _buildLetter(int index, String letter, double progress) {
    if (letter == ' ') {
      return const SizedBox(width: 8);
    }

    // Staggered vertical sine-wave offset
    final wave = math.sin((progress * 2 * math.pi) - (index * 0.45));
    final offsetY = wave * 5.0;

    // Dynamic gradient color shift across the letters
    final colorFactor = ((math.sin((progress * 2 * math.pi) + (index * 0.3)) + 1) / 2);
    final letterColor = Color.lerp(
      AppTheme.primaryDeepBlue,
      AppTheme.buttonColor,
      colorFactor,
    );

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Text(
        letter,
        style: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: letterColor,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: AppTheme.buttonColor.withValues(alpha: 0.25 * colorFactor),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(double progress) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (dotIndex) {
        final dotProgress = (progress * 3 - dotIndex) % 1.0;
        final dotWave = math.sin(dotProgress * math.pi);
        final dotOffset = -dotWave * 8.0;

        return Transform.translate(
          offset: Offset(0, dotOffset),
          child: Text(
            ".",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.buttonColor,
            ),
          ),
        );
      }),
    );
  }
}
