import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../Utilities/app_fonts.dart';

class ReviewVideoWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double height;
  final double width;
  final VoidCallback? onDelete;

  const ReviewVideoWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.height = 140,
    this.width = double.infinity,
    this.onDelete,
  });

  @override
  State<ReviewVideoWidget> createState() => _ReviewVideoWidgetState();
}

class _ReviewVideoWidgetState extends State<ReviewVideoWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant ReviewVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl || oldWidget.videoFile != widget.videoFile) {
      _disposeController();
      _initVideo();
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  Future<void> _initVideo() async {
    try {
      if (widget.videoFile != null && widget.videoFile!.existsSync()) {
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else if (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty) {
        final uri = Uri.parse(widget.videoUrl!.trim());
        _controller = VideoPlayerController.networkUrl(uri);
      } else {
        setState(() => _hasError = true);
        return;
      }

      await _controller!.initialize();
      _controller!.setLooping(false);
      _controller!.setVolume(1.0);
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
    _disposeController();
    super.dispose();
  }

  void _playVideoDialog(BuildContext context) {
    if ((widget.videoUrl == null || widget.videoUrl!.trim().isEmpty) &&
        (widget.videoFile == null || !widget.videoFile!.existsSync())) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(
          videoUrl: widget.videoUrl,
          videoFile: widget.videoFile,
          existingController: _isInitialized ? _controller : null,
        ),
      ),
    ).then((_) {
      _controller?.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _playVideoDialog(context),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller!.value.size.width > 0
                        ? _controller!.value.size.width
                        : 300,
                    height: _controller!.value.size.height > 0
                        ? _controller!.value.size.height
                        : 200,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: _hasError
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_outlined, color: Colors.white54, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                "Video Review",
                                style: AppFonts.regularText.copyWith(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          )
                        : const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                  ),
                ),
              // Semi-transparent overlay & play icon
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              // Top left Video badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "Video Review",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // Optional Delete button (for review submission preview)
              if (widget.onDelete != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
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

class FullScreenVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final VideoPlayerController? existingController;

  const FullScreenVideoPlayer({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.existingController,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isOwnedController = false;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.existingController != null && widget.existingController!.value.isInitialized) {
      _controller = widget.existingController;
      _isOwnedController = false;
      _isInitialized = true;
      if (_controller!.value.duration > Duration.zero &&
          _controller!.value.position >= _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
      }
      _controller!.play();
      _controller!.addListener(_onControllerUpdate);
      if (mounted) setState(() {});
      return;
    }

    try {
      if (widget.videoFile != null && widget.videoFile!.existsSync()) {
        _controller = VideoPlayerController.file(widget.videoFile!);
        _isOwnedController = true;
      } else if (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty) {
        final uri = Uri.parse(widget.videoUrl!.trim());
        _controller = VideoPlayerController.networkUrl(uri);
        _isOwnedController = true;
      } else {
        if (mounted) setState(() => _hasError = true);
        return;
      }

      await _controller!.initialize();
      _controller!.setLooping(false);
      _controller!.setVolume(1.0);
      _controller!.play();
      _controller!.addListener(_onControllerUpdate);
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

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_onControllerUpdate);
      if (_isOwnedController) {
        _controller!.pause();
        _controller!.dispose();
      } else {
        _controller!.pause();
      }
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller?.value;
    final position = value?.position ?? Duration.zero;
    final duration = value?.duration ?? Duration.zero;
    final isPlaying = value?.isPlaying ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video center display
            Center(
              child: _isInitialized && _controller != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio > 0
                            ? _controller!.value.aspectRatio
                            : 16 / 9,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  : (_hasError
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline, color: Colors.white54, size: 48),
                            SizedBox(height: 12),
                            Text("Unable to load video review", style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      : const CircularProgressIndicator(color: Colors.white)),
            ),

            // Top Header Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Video Review",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center Play / Pause toggle icon
            if (_showControls && _isInitialized && _controller != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

            // Bottom controls bar with progress indicator & time text
            if (_isInitialized && _controller != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.redAccent,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_formatDuration(position)} / ${_formatDuration(duration)}",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isPlaying) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
