import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/ngo_details_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

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

  Future<void> fetchNgoDetails() async {
    if (ngoId.isEmpty) {
      errorMessage.value = 'NGO ID is missing.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Repositories().getApi(
        url: ApiUrls.getNgoDetailsUrl(ngoId),
        showResponse: true,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        final model = NgoDetailsModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          ngoDetails.value = model.data;
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

  Future<bool> submitReview(String targetName, int rating, String comment) async {
    try {
      isSubmittingReview.value = true;
      var body = {
        "type": "ngo",
        "targetName": targetName,
        "rating": rating,
        "comment": comment
      };

      final response = await Repositories().postApi(
        url: ApiUrls.submitReviewUrl,
        showResponse: true,
        mapData: body,
      );

      if (response != null) {
        final jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          Get.snackbar("Success", jsonResponse['message'] ?? "Review submitted successfully", backgroundColor: Colors.black87, colorText: Colors.white);
          return true;
        } else {
          Get.snackbar("Error", jsonResponse['message'] ?? 'Failed to submit review', backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", "Something went wrong", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }
}
