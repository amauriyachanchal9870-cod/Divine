import 'dart:convert';
import 'dart:io';
import 'package:divine_foundation/Utilities/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/ngo_details_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

import '../Model/review_model.dart';

class NgoDetailsController extends GetxController {
  final String ngoId;
  var isLoading = false.obs;
  var ngoDetails = Rxn<NgoDetailsData>();
  var errorMessage = ''.obs;
  var isSubmittingReview = false.obs;

  NgoDetailsController({required this.ngoId});

  @override
  void onInit() {
    super.onInit();
    fetchNgoDetails();
  }

  Future<void> fetchNgoDetails({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && ngoDetails.value != null) return;
    if (ngoId.isEmpty) {
      errorMessage.value = 'NGO ID is missing.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = ApiUrls.getNgoDetailsUrl(ngoId);
      debugPrint("==================================================");
      debugPrint("🌐 [NGO DETAILS API REQUEST]");
      debugPrint("🌐 NGO ID: $ngoId");
      debugPrint("🌐 URL: $url");
      debugPrint("==================================================");

      final response = await Repositories().getApi(
        url: url,
        showResponse: true,
      );

      debugPrint("==================================================");
      debugPrint("📥 [NGO DETAILS API RESPONSE]");
      debugPrint("📥 URL: $url");
      debugPrint("📥 Response Body: $response");
      debugPrint("==================================================");

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = NgoDetailsModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          ngoDetails.value = model.data;
          
          if (ngoDetails.value!.reviews == null || ngoDetails.value!.reviews!.isEmpty) {
            await fetchReviewsFallback();
          }
        } else {
          errorMessage.value = 'Failed to load NGO details.';
        }
      } else {
        errorMessage.value = 'No response from server.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint("Error fetching NGO details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviewsFallback() async {
    try {
      final response = await Repositories().getApi(
        url: ApiUrls.donorReviewsUrl,
        showResponse: false,
      );
      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final reviewModel = ReviewModel.fromJson(jsonResponse);
        if (reviewModel.status == true && reviewModel.data != null && reviewModel.data!.isNotEmpty) {
          final ngoName = ngoDetails.value?.name?.toLowerCase() ?? '';
          final matched = reviewModel.data!.where((r) {
            if (ngoName.isEmpty) return true;
            final target = (r.targetName ?? '').toLowerCase();
            return target.contains(ngoName) || ngoName.contains(target);
          }).toList();

          final finalReviews = matched.isNotEmpty ? matched : reviewModel.data!;
          if (ngoDetails.value != null) {
            ngoDetails.value!.reviews = finalReviews;
            if (ngoDetails.value!.reviewCount == null || ngoDetails.value!.reviewCount == 0) {
              ngoDetails.value!.reviewCount = finalReviews.length;
            }
            ngoDetails.refresh();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching fallback reviews: $e");
    }
  }

  Future<bool> addReview(
    String targetName,
    int rating,
    String comment, {
    String type = "NGO",
    dynamic videoFile,
  }) async {
    try {
      isSubmittingReview.value = true;
      dynamic response;

      if (videoFile != null) {
        if (videoFile is File && videoFile.existsSync()) {
          final int sizeInBytes = await videoFile.length();
          const int max10MB = 10 * 1024 * 1024;
          if (sizeInBytes > max10MB) {
            showSnackBar("Video size must not exceed 10 MB", false);
            return false;
          }
        }

        String? base64Video;
        try {
          if (videoFile is File && videoFile.existsSync()) {
            final bytes = await videoFile.readAsBytes();
            base64Video = "data:video/mp4;base64,${base64Encode(bytes)}";
          }
        } catch (e) {
          debugPrint("Error encoding video to base64: $e");
        }

        if (base64Video != null) {
          var body = {
            "type": type,
            "targetName": targetName,
            "rating": rating,
            "comment": comment,
            "video": base64Video,
            "videoUrl": base64Video
          };

          response = await Repositories().postApi(
            url: ApiUrls.addReviewUrl,
            showResponse: true,
            mapData: body,
          );
        } else {
          final Map<String, String> body = {
            "type": type,
            "targetName": targetName,
            "rating": rating.toString(),
            "comment": comment,
          };
          response = await Repositories().multiPartApi(
            url: ApiUrls.addReviewUrl,
            mapData: body,
            images: {"video": videoFile},
            onProgress: (bytes, totalBytes) {},
          );
        }
      } else {
        var body = {
          "type": type,
          "targetName": targetName,
          "rating": rating,
          "comment": comment
        };

        response = await Repositories().postApi(
          url: ApiUrls.addReviewUrl,
          showResponse: true,
          mapData: body,
        );
      }

      if (response != null) {
        final jsonResponse = response is String ? jsonDecode(response) : response;
        if (jsonResponse['status'] == true || jsonResponse['success'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Review submitted successfully", true);
          fetchNgoDetails(forceRefresh: true);
          return true;
        } else {
          showSnackBar(jsonResponse['message'] ?? 'Failed to submit review', false);
          return false;
        }
      }
      return false;
    } catch (e) {
      showSnackBar("Something went wrong: ${e.toString()}", false);
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<bool> submitReview(String targetName, int rating, String comment, {dynamic videoFile}) async {
    return addReview(targetName, rating, comment, videoFile: videoFile);
  }
}
