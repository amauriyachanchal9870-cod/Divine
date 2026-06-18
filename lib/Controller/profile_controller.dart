import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/profile_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = Rxn<ProfileData>();

  Future<void> fetchProfile(BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await Repositories().getApi(
        context: context,
        url: ApiUrls.profileUrl,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        ProfileModel profileModel = ProfileModel.fromJson(jsonResponse);
        if (profileModel.status == true) {
          profileData.value = profileModel.data;
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
