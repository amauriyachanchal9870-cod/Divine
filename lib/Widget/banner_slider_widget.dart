import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../Model/screen_banner_model.dart';
import '../Routes/my_routes.dart';
import '../Utilities/app_fonts.dart';
import '../Utilities/app_theme.dart';

class BannerSliderWidget extends StatefulWidget {
  final List<BannerItem> banners;
  final double height;
  final EdgeInsetsGeometry padding;
  final String? placeholderTitle;

  const BannerSliderWidget({
    super.key,
    required this.banners,
    this.height = 155,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.placeholderTitle,
  });

  @override
  State<BannerSliderWidget> createState() => _BannerSliderWidgetState();
}

class _BannerSliderWidgetState extends State<BannerSliderWidget> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    if (widget.banners.length > 1) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        int nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant BannerSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap(BannerItem banner) {
    final target = banner.effectiveTarget;
    if (target.isEmpty) return;

    if (target.contains('/campaigns') || target.contains('campaign_list')) {
      Get.toNamed(MyRouters.ongoingCampaignScreen);
    } else if (target.contains('/donate') || target.contains('donate')) {
      Get.toNamed(MyRouters.chooseDaanTypeScreen);
    } else if (target.contains('/ngos') || target.contains('ngos')) {
      Get.toNamed(MyRouters.ngosScreen);
    } else if (target.contains('/wallet') || target.contains('wallet')) {
      Get.toNamed(MyRouters.walletScreen);
    } else if (target.contains('/following') || target.contains('following')) {
      Get.toNamed(MyRouters.followingNgosScreen);
    } else {
      // General fallback route check
      try {
        Get.toNamed(target);
      } catch (e) {
        if (kDebugMode) {
          print("Route error: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return GestureDetector(
                    onTap: () => _handleBannerTap(banner),
                    child: _BannerCardItem(banner: banner, height: widget.height),
                  );
                },
              ),
            ),
          ),
          if (widget.banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppTheme.primaryDeepBlue
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerCardItem extends StatelessWidget {
  final BannerItem banner;
  final double height;

  const _BannerCardItem({required this.banner, required this.height});

  @override
  Widget build(BuildContext context) {
    final mediaUrl = banner.effectiveMediaUrl;
    final title = banner.title ?? '';
    final subtitle = banner.subtitle ?? '';

    Widget mediaWidget;

    if (banner.isVideo) {
      mediaWidget = _VideoBannerMedia(videoUrl: banner.videoUrl ?? mediaUrl);
    } else if (banner.isBase64) {
      mediaWidget = _buildBase64Image(mediaUrl);
    } else if (mediaUrl.isNotEmpty) {
      mediaWidget = CachedNetworkImage(
        imageUrl: mediaUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.bannerBgColor,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackBanner(),
      );
    } else {
      mediaWidget = _buildFallbackBanner();
    }

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bannerBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: mediaWidget,
            ),
          ),
          if (title.isNotEmpty || subtitle.isNotEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.semiBoldText.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.regularText.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (banner.subscriptionPlan != null && banner.subscriptionPlan!.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDeepBlue.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  banner.subscriptionPlan!,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(String dataUrl) {
    try {
      final parts = dataUrl.split(',');
      final base64Str = parts.length > 1 ? parts[1] : parts[0];
      final bytes = base64Decode(base64Str.replaceAll(RegExp(r'\s+'), ''));
      return Image.memory(
        bytes,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
      );
    } catch (e) {
      return _buildFallbackBanner();
    }
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bannerBgColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.bannerBgColor,
            AppTheme.primaryDeepBlue.withValues(alpha: 0.15),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner.title != null && banner.title!.isNotEmpty)
            Text(
              banner.title!,
              style: AppFonts.titleStyle.copyWith(fontSize: 16, color: AppTheme.primaryDeepBlue),
            ),
          if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              banner.subtitle!,
              style: AppFonts.regularText.copyWith(fontSize: 12, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoBannerMedia extends StatefulWidget {
  final String videoUrl;

  const _VideoBannerMedia({required this.videoUrl});

  @override
  State<_VideoBannerMedia> createState() => _VideoBannerMediaState();
}

class _VideoBannerMediaState extends State<_VideoBannerMedia> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.videoUrl.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white54, size: 36),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: AppTheme.bannerBgColor,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
