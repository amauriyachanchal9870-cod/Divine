import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Controller/home_controller.dart';
import '../Controller/my_campaigns_controller.dart';
import '../Controller/my_reviews_controller.dart';
import '../Controller/profile_controller.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/app_fonts.dart';
import '../Utilities/app_theme.dart';
import '../Utilities/helper.dart';
import 'review_video_widget.dart';

bool isSelfCampaign({
  String? campaignUserId,
  String? campaignUser,
  String? campaignId,
  String? campaignSId,
  bool defaultSelf = false,
}) {
  if (defaultSelf) return true;

  final currentUserId = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>().homeData.value?.user?.id
      : (Get.isRegistered<ProfileController>() ? Get.find<ProfileController>().profileData.value?.id : null);
  final currentUserName = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>().homeData.value?.user?.name
      : (Get.isRegistered<ProfileController>() ? Get.find<ProfileController>().profileData.value?.name : null);

  if (currentUserId != null && currentUserId.isNotEmpty) {
    if (campaignUserId != null && campaignUserId.isNotEmpty && campaignUserId == currentUserId) return true;
    if (campaignUser != null && campaignUser.isNotEmpty && campaignUser == currentUserId) return true;
  }
  if (currentUserName != null && currentUserName.isNotEmpty && campaignUser != null && campaignUser.isNotEmpty) {
    if (campaignUser.trim().toLowerCase() == currentUserName.trim().toLowerCase()) return true;
  }

  if (Get.isRegistered<MyCampaignsController>()) {
    final myCamps = Get.find<MyCampaignsController>().myCampaignsData.value?.myCampaigns;
    if (myCamps != null) {
      for (var mc in myCamps) {
        if ((campaignSId != null && mc.sId == campaignSId) ||
            (campaignId != null && mc.campaignId == campaignId)) {
          return true;
        }
      }
    }
  }

  return false;
}

bool canShowCampaignReviewButton({
  required bool isSelf,
  required bool isCompleted,
}) {
  return isSelf && isCompleted;
}

void showCampaignReviewBottomSheet({
  required BuildContext context,
  required String campaignId,
  String? campaignTitle,
  VoidCallback? onSuccess,
}) {
  int selectedStars = 0;
  final TextEditingController feedbackController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier<bool>(false);
  XFile? selectedVideo;
  final ImagePicker picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Rate Campaign",
                            style: AppFonts.titleStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(sheetContext),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 20, color: Color(0xFF475569)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      campaignTitle != null && campaignTitle.isNotEmpty
                          ? campaignTitle
                          : "Tell us your experience",
                      style: AppFonts.regularText.copyWith(color: const Color(0xFF64748B), fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStars = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star,
                              color: index < selectedStars ? const Color(0xFFFFB800) : Colors.grey.shade300,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        maxLength: 200,
                        onChanged: (_) => setState(() {}),
                        style: AppFonts.regularText.copyWith(fontSize: 14, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Write your Review...",
                          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          counterText: "",
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${feedbackController.text.length}/200",
                        style: AppFonts.regularText.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedVideo != null)
                      ReviewVideoWidget(
                        videoFile: File(selectedVideo!.path),
                        height: 130,
                        width: double.infinity,
                        onDelete: () {
                          setState(() {
                            selectedVideo = null;
                          });
                        },
                      )
                    else
                      InkWell(
                        onTap: () async {
                          final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                          if (video != null) {
                            final file = File(video.path);
                            if (file.existsSync()) {
                              final int sizeInBytes = await file.length();
                              const int max10MB = 10 * 1024 * 1024;
                              if (sizeInBytes > max10MB) {
                                showSnackBar("Video size must not exceed 10 MB", false);
                                return;
                              }
                            }
                            setState(() {
                              selectedVideo = video;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.fieldBorderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_outlined, color: Color(0xFF1E293B), size: 22),
                              const SizedBox(width: 8),
                              Text(
                                "Upload Video Review (Optional)",
                                style: AppFonts.semiBoldText.copyWith(
                                  color: const Color(0xFF1E293B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFE2E8F0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                "May be later",
                                style: AppFonts.semiBoldText.copyWith(
                                  color: const Color(0xFF475569),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isSubmitting,
                              builder: (context, loading, _) {
                                return ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () async {
                                          if (selectedStars <= 0) {
                                            showSnackBar("Rating is required", false);
                                            return;
                                          }
                                          if (feedbackController.text.trim().isEmpty) {
                                            showSnackBar("Review message is required", false);
                                            return;
                                          }
                                          isSubmitting.value = true;
                                          try {
                                            File? videoFile = selectedVideo != null ? File(selectedVideo!.path) : null;
                                            String? videoUrl;

                                            if (videoFile != null && videoFile.existsSync()) {
                                              final int sizeInBytes = await videoFile.length();
                                              const int max10MB = 10 * 1024 * 1024;
                                              if (sizeInBytes > max10MB) {
                                                showSnackBar("Video size must not exceed 10 MB", false);
                                                isSubmitting.value = false;
                                                return;
                                              }

                                              // Upload to Catbox
                                              try {
                                                final client = http.Client();
                                                try {
                                                  final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
                                                  request.fields['reqtype'] = 'fileupload';
                                                  request.files.add(await http.MultipartFile.fromPath('fileToUpload', videoFile.path));
                                                  final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
                                                  final responseData = await streamedResponse.stream.bytesToString();
                                                  if (streamedResponse.statusCode == 200 && responseData.trim().startsWith('https://files.catbox.moe/')) {
                                                    videoUrl = responseData.trim();
                                                  }
                                                } finally {
                                                  client.close();
                                                }
                                              } catch (e) {
                                                debugPrint("Catbox video upload failed: $e");
                                              }

                                              // Fallback to base64 encoding (matching NGO review implementation)
                                              if (videoUrl == null || videoUrl.isEmpty) {
                                                try {
                                                  final bytes = await videoFile.readAsBytes();
                                                  videoUrl = "data:video/mp4;base64,${base64Encode(bytes)}";
                                                } catch (e) {
                                                  debugPrint("Base64 video encoding error: $e");
                                                }
                                              }
                                            }

                                            final body = {
                                              "rating": selectedStars.toString(),
                                              "comment": feedbackController.text.trim(),
                                              if (videoUrl != null && videoUrl.isNotEmpty) ...{
                                                "video": videoUrl,
                                                "videoUrl": videoUrl,
                                                "mediaUrl": videoUrl,
                                              },
                                            };
                                            final response = await Repositories().postApi(
                                              url: ApiUrls.campaignReviewsUrl(campaignId),
                                              showResponse: true,
                                              mapData: body,
                                            );
                                            if (response != null) {
                                              final jsonResponse = response is String ? jsonDecode(response) : response;
                                              if (jsonResponse['status'] == true || jsonResponse['success'] == true) {
                                                showSnackBar(
                                                  jsonResponse['message'] ?? "Review submitted successfully for campaign",
                                                  true,
                                                );
                                                if (Get.isRegistered<MyReviewsController>()) {
                                                  Get.find<MyReviewsController>().fetchReviews(forceRefresh: true);
                                                }
                                                if (sheetContext.mounted) {
                                                  Navigator.pop(sheetContext);
                                                }
                                                if (context.mounted) {
                                                  _showThanksBottomSheet(context, selectedStars);
                                                }
                                                onSuccess?.call();
                                              } else {
                                                showSnackBar(
                                                  jsonResponse['message'] ?? "Failed to submit review",
                                                  false,
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            showSnackBar("Something went wrong: ${e.toString()}", false);
                                          } finally {
                                            isSubmitting.value = false;
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryDeepBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Submit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

String _getSmileyForRating(int rating) {
  switch (rating) {
    case 1:
      return "😡";
    case 2:
      return "🙁";
    case 3:
      return "😐";
    case 4:
      return "🙂";
    case 5:
      return "😍";
    default:
      return "😍";
  }
}

void _showThanksBottomSheet(BuildContext context, int rating) {
  final String smiley = _getSmileyForRating(rating);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(smiley, style: const TextStyle(fontSize: 48)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.greyBg50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text("Thanks!", style: AppFonts.titleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Tell us your experience", style: AppFonts.regularText.copyWith(color: AppTheme.textGrey500)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    color: index < rating ? AppTheme.amberStars : Colors.grey.shade300,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
