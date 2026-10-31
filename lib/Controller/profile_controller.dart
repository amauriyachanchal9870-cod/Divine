import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/profile_model.dart';
import '../Model/support_ticket_model.dart';
import '../Model/coupon_model.dart';
import '../Model/referral_model.dart';
import '../Model/my_campaigns_model.dart';
import '../Repo/common_repo.dart';
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';
import 'home_controller.dart';
import 'wallet_controller.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = Rxn<ProfileData>();

  var privacyTitle = "".obs;
  var privacyContent = "".obs;
  var termsTitle = "".obs;
  var termsContent = "".obs;
  var aboutTitle = "".obs;
  var aboutContent = "".obs;

  var ticketsList = <SupportTicket>[].obs;
  var isTicketsLoading = false.obs;

  var couponsList = <Coupon>[].obs;
  var isCouponsLoading = false.obs;

  var referralData = Rxn<ReferralData>();
  var isReferralLoading = false.obs;

  var myCampaignsData = Rxn<MyCampaignsModel>();
  var isMyCampaignsLoading = false.obs;

  void _safeSetLoading(RxBool target, bool val) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        target.value = val;
      });
    } else {
      target.value = val;
    }
  }

  Future<void> fetchContent(BuildContext context, String slug) async {
    _safeSetLoading(isLoading, true);
    try {
      final response = await Repositories().getApi(
        context: null,
        url: "${ApiUrls.apiBaseUrl}/donor/content/$slug",
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          String title = jsonResponse['title'] ?? "";
          String content = jsonResponse['content'] ?? "";
          if (slug == "privacy-policy") {
            privacyTitle.value = title;
            privacyContent.value = content;
          } else if (slug.startsWith("terms")) {
            termsTitle.value = title;
            termsContent.value = content;
          } else if (slug == "about-us") {
            aboutTitle.value = title;
            aboutContent.value = content;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching content ($slug): $e");
    } finally {
      _safeSetLoading(isLoading, false);
    }
  }

  Future<void> fetchProfile(BuildContext context, {bool forceRefresh = false}) async {
    if (isLoading.value) return;
    if (!forceRefresh && profileData.value != null) return;

    _safeSetLoading(isLoading, true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? profileData.value?.role;
      String primaryUrl = (role == 'ngo' || role == 'corporate' || profileData.value?.role == 'ngo' || profileData.value?.role == 'corporate') ? ApiUrls.ngoProfileUrl : ApiUrls.profileUrl;

      dynamic response = await Repositories().getApi(
        context: null,
        url: primaryUrl,
      );

      bool loaded = false;
      if (response != null) {
        var jsonResponse = jsonDecode(response);
        ProfileModel profileModel = ProfileModel.fromJson(jsonResponse);
        if (profileModel.data != null) {
          final existingPhoto = profileData.value?.profilePhoto ?? profileData.value?.logo;
          final serverPhoto = profileModel.data!.profilePhoto ?? profileModel.data!.logo;
          if (serverPhoto == null || serverPhoto.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            final cached = prefs.getString('saved_profile_photo') ?? prefs.getString('userProfilePhoto');
            final fallback = (existingPhoto != null && existingPhoto.isNotEmpty) ? existingPhoto : cached;
            if (fallback != null && fallback.isNotEmpty) {
              profileModel.data!.profilePhoto = fallback;
              profileModel.data!.logo = fallback;
            }
          } else {
            profileModel.data!.profilePhoto ??= serverPhoto;
            profileModel.data!.logo ??= serverPhoto;
          }
          profileData.value = profileModel.data;
          loaded = true;
        }
      }

      // If primary endpoint failed or returned empty profile data, try alternate endpoint
      if (!loaded) {
        String altUrl = (primaryUrl == ApiUrls.ngoProfileUrl) ? ApiUrls.profileUrl : ApiUrls.ngoProfileUrl;
        dynamic altResponse = await Repositories().getApi(
          context: null,
          url: altUrl,
        );
        if (altResponse != null) {
          var jsonResponse = jsonDecode(altResponse);
          ProfileModel profileModel = ProfileModel.fromJson(jsonResponse);
          if (profileModel.data != null) {
            final existingPhoto = profileData.value?.profilePhoto ?? profileData.value?.logo;
            final serverPhoto = profileModel.data!.profilePhoto ?? profileModel.data!.logo;
            if (serverPhoto == null || serverPhoto.isEmpty) {
              final prefs = await SharedPreferences.getInstance();
              final cached = prefs.getString('saved_profile_photo') ?? prefs.getString('userProfilePhoto');
              final fallback = (existingPhoto != null && existingPhoto.isNotEmpty) ? existingPhoto : cached;
              if (fallback != null && fallback.isNotEmpty) {
                profileModel.data!.profilePhoto = fallback;
                profileModel.data!.logo = fallback;
              }
            } else {
              profileModel.data!.profilePhoto ??= serverPhoto;
              profileModel.data!.logo ??= serverPhoto;
            }
            profileData.value = profileModel.data;
            loaded = true;
          }
        }
      }

      // Fallback merge from HomeController if certain user fields (phone/name/walletBalance) are still missing
      if (profileData.value != null && Get.isRegistered<HomeController>()) {
        final homeUser = Get.find<HomeController>().homeData.value?.user;
        if (homeUser != null) {
          if (profileData.value!.phone == null || profileData.value!.phone!.isEmpty) {
            profileData.value!.phone = homeUser.phone;
          }
          if (profileData.value!.name == null || profileData.value!.name!.isEmpty) {
            profileData.value!.name = homeUser.name;
          }
          if ((profileData.value!.walletBalance == null || profileData.value!.walletBalance == 0) &&
              homeUser.walletBalance != null &&
              homeUser.walletBalance! > 0) {
            profileData.value!.walletBalance = homeUser.walletBalance?.toDouble();
          }
          profileData.refresh();
        }
      }

      if (profileData.value != null && Get.isRegistered<WalletController>()) {
        final wCtrl = Get.find<WalletController>();
        if ((profileData.value!.walletBalance == null || profileData.value!.walletBalance == 0) &&
            wCtrl.walletBalance.value > 0) {
          profileData.value!.walletBalance = wCtrl.walletBalance.value;
          profileData.refresh();
        } else if (profileData.value!.walletBalance != null && profileData.value!.walletBalance! > 0) {
          wCtrl.walletBalance.value = profileData.value!.walletBalance!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _safeSetLoading(isLoading, false);
    }
  }

  Future<String?> uploadFile(File file) async {
    if (!file.existsSync()) {
      print("❌ [uploadFile] File does not exist at path: ${file.path}");
      return null;
    }

    print("📸 [uploadFile] Starting upload for: ${file.path}");
    print("📸 [uploadFile] File size: ${file.lengthSync()} bytes");

    // Check ImgBB API key is configured
    const imgbbKey = ApiUrls.imgbbApiKey;
    if (imgbbKey == 'YOUR_IMGBB_API_KEY_HERE' || imgbbKey.isEmpty) {
      print("⚠️ [uploadFile] ImgBB API key not configured! Get a free key at https://api.imgbb.com/");
      print("⚠️ [uploadFile] Then set it in ApiUrls.imgbbApiKey in api_constant.dart");
    }

    final bool isPdf = file.path.toLowerCase().endsWith('.pdf');

    // Server 1: ImgBB — base64 POST upload for IMAGES ONLY.
    // Base64 upload bypasses ISP multipart blocking. ImgBB only supports images and converts PDFs to JPG images.
    if (!isPdf && imgbbKey != 'YOUR_IMGBB_API_KEY_HERE' && imgbbKey.isNotEmpty) {
      print("🔄 [uploadFile] Trying Server 1: ImgBB (base64)...");
      try {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final response = await http.post(
          Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbKey'),
          body: {'image': base64Image},
        ).timeout(const Duration(seconds: 30));
        print("✅ [ImgBB] Status: ${response.statusCode}");
        print("✅ [ImgBB] Response: ${response.body}");
        if (response.statusCode == 200) {
          final jsonResp = jsonDecode(response.body);
          if (jsonResp['success'] == true) {
            // Use display_url (direct image link) for best browser compatibility
            final url = jsonResp['data']['display_url']?.toString()
                ?? jsonResp['data']['url']?.toString()
                ?? '';
            if (url.isNotEmpty) {
              print("✅ [ImgBB] Upload SUCCESS: $url");
              return url;
            }
          }
          print("⚠️ [ImgBB] Unexpected response: ${response.body}");
        } else {
          print("⚠️ [ImgBB] Non-200 status: ${response.statusCode}, body: ${response.body}");
        }
      } catch (e, stackTrace) {
        print("❌ [ImgBB] EXCEPTION: $e");
        print("❌ [ImgBB] StackTrace: $stackTrace");
      }
    }

    // Server 2: Catbox — permanent URL (https://files.catbox.moe/xxxxx.jpg)
    // Note: May be blocked on some Indian mobile IPs. Use WiFi or after ImgBB is configured.
    print("🔄 [uploadFile] Trying Server 2: Catbox (45s)...");
    try {
      final client = http.Client();
      try {
        final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
        request.fields['reqtype'] = 'fileupload';
        request.files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        final responseData = await streamedResponse.stream.bytesToString();
        print("✅ [Catbox] Status: ${streamedResponse.statusCode}");
        print("✅ [Catbox] Response: $responseData");
        if (streamedResponse.statusCode == 200) {
          final url = responseData.trim();
          if (url.startsWith('https://files.catbox.moe/')) {
            print("✅ [Catbox] Upload SUCCESS: $url");
            return url;
          } else {
            print("⚠️ [Catbox] Unexpected response: $responseData");
          }
        } else {
          print("⚠️ [Catbox] Non-200 status: ${streamedResponse.statusCode}, body: $responseData");
        }
      } finally {
        client.close();
      }
    } catch (e, stackTrace) {
      print("❌ [Catbox] EXCEPTION: $e");
      print("❌ [Catbox] StackTrace: $stackTrace");
    }

    // Server 3: ImgBB retry — second attempt with multipart instead of base64 (IMAGES ONLY)
    if (!isPdf && imgbbKey != 'YOUR_IMGBB_API_KEY_HERE' && imgbbKey.isNotEmpty) {
      print("🔄 [uploadFile] Trying Server 3: ImgBB (multipart retry)...");
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbKey'),
        );
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
        final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
        final responseData = await streamedResponse.stream.bytesToString();
        print("✅ [ImgBB-retry] Status: ${streamedResponse.statusCode}");
        print("✅ [ImgBB-retry] Response: $responseData");
        if (streamedResponse.statusCode == 200) {
          final jsonResp = jsonDecode(responseData);
          if (jsonResp['success'] == true) {
            final url = jsonResp['data']['display_url']?.toString()
                ?? jsonResp['data']['url']?.toString()
                ?? '';
            if (url.isNotEmpty) {
              print("✅ [ImgBB-retry] Upload SUCCESS: $url");
              return url;
            }
          }
          print("⚠️ [ImgBB-retry] Unexpected response: $responseData");
        } else {
          print("⚠️ [ImgBB-retry] Non-200 status: ${streamedResponse.statusCode}");
        }
      } catch (e, stackTrace) {
        print("❌ [ImgBB-retry] EXCEPTION: $e");
        print("❌ [ImgBB-retry] StackTrace: $stackTrace");
      }
    }

    print("❌ [uploadFile] ALL servers failed. Returning null.");
    return null;
  }

  Future<bool> updateProfile({
    required BuildContext context,
    required Map<String, dynamic> mapData,
    File? imageFile,
  }) async {
    isLoading.value = true;
    OverlayEntry loader = Helpers.overlayLoader(context);
    Overlay.of(context).insert(loader);

    try {
      if (profileData.value == null) {
        await fetchProfile(context, forceRefresh: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? profileData.value?.role ?? 'donor';
      final String url = (role == 'ngo' || role == 'corporate' || profileData.value?.role == 'ngo' || profileData.value?.role == 'corporate') ? ApiUrls.ngoProfileUrl : ApiUrls.profileUrl;

      final Map<String, dynamic> finalMapData = {};
      if (profileData.value != null) {
        final existingMap = profileData.value!.toJson();
        const skipKeys = {
          '_id', 'id', 'reviews', 'couponsClaimed', 'followers', 'followingNgos',
          'followingUsers', 'searchHistory', 'createdAt', 'updatedAt', 'otp',
          'otpExpiry', 'rating', 'reviewCount'
        };
        existingMap.forEach((key, value) {
          if (value != null && !skipKeys.contains(key)) {
            finalMapData[key] = value;
          }
        });
      }
      mapData.forEach((key, value) {
        if (value != null) {
          finalMapData[key] = value;
        }
      });

      String? uploadedPhotoUrl;
      if (imageFile != null && imageFile.existsSync()) {
        final String? uploadedUrl = await uploadFile(imageFile);
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          Helpers.hideLoader(loader);
          showSnackBar("Image upload failed. Please try again.", false);
          print("❌ Image upload failed. No URL returned.");
          return false;
        }
        uploadedPhotoUrl = uploadedUrl;
        finalMapData['profilePhoto'] = uploadedUrl;
        finalMapData['profile_photo'] = uploadedUrl;
        finalMapData['logo'] = uploadedUrl;
        finalMapData['logoUrl'] = uploadedUrl;
        finalMapData['logo_url'] = uploadedUrl;
        finalMapData['photoUrl'] = uploadedUrl;
        finalMapData['photo_url'] = uploadedUrl;
        finalMapData['userImage'] = uploadedUrl;
        finalMapData['user_image'] = uploadedUrl;
        finalMapData['image'] = uploadedUrl;
        finalMapData['imageUrl'] = uploadedUrl;
        finalMapData['avatar'] = uploadedUrl;
        finalMapData['photo'] = uploadedUrl;
        log("📸 Updated Profile Photo URL in payload: $uploadedUrl");

        if (profileData.value != null) {
          profileData.value!.profilePhoto = uploadedUrl;
          profileData.value!.logo = uploadedUrl;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userProfilePhoto', uploadedUrl);
        await prefs.setString('saved_profile_photo', uploadedUrl);
      }

      debugPrint("\n======= UPDATE PROFILE REQUEST =======");
      debugPrint("🌐 URL: $url");
      debugPrint("📦 PAYLOAD: ${jsonEncode(finalMapData)}", wrapWidth: 1024);
      debugPrint("=====================================");

      final response = await Repositories().putApi(
        context: null,
        url: url,
        mapData: finalMapData,
      );

      debugPrint("\n======= UPDATE PROFILE RESPONSE =======");
      debugPrint("📩 RAW RESPONSE: $response", wrapWidth: 1024);
      debugPrint("======================================");

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          String? newPhotoUrl = uploadedPhotoUrl;
          if (newPhotoUrl == null && finalMapData.containsKey('profilePhoto') && finalMapData['profilePhoto'] != null && finalMapData['profilePhoto'].toString().trim().isNotEmpty) {
            newPhotoUrl = finalMapData['profilePhoto'].toString().trim();
          }

          var userObj = jsonResponse['user'] ?? jsonResponse['data'] ?? jsonResponse['ngo'] ?? jsonResponse['profile'];
          if (userObj != null && userObj is Map<String, dynamic> && (userObj.containsKey('name') || userObj.containsKey('organizationName') || userObj.containsKey('_id') || userObj.containsKey('phone'))) {
            try {
              ProfileData updatedProfile = ProfileData.fromJson(userObj);
              if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
                updatedProfile.profilePhoto = newPhotoUrl;
                updatedProfile.logo = newPhotoUrl;
              }
              if (updatedProfile.profilePhoto != null && updatedProfile.profilePhoto!.isNotEmpty) {
                updatedProfile.logo ??= updatedProfile.profilePhoto;
              } else if (updatedProfile.logo != null && updatedProfile.logo!.isNotEmpty) {
                updatedProfile.profilePhoto ??= updatedProfile.logo;
              }
              profileData.value = updatedProfile;
            } catch (e) {
              debugPrint("Error parsing profile update data: $e");
            }
          } else if (newPhotoUrl != null && newPhotoUrl.isNotEmpty && profileData.value != null) {
            profileData.value!.profilePhoto = newPhotoUrl;
            profileData.value!.logo = newPhotoUrl;
          }

          if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userProfilePhoto', newPhotoUrl);
            await prefs.setString('saved_profile_photo', newPhotoUrl);
          }

          Helpers.hideLoader(loader);
          isLoading.value = false;

          await fetchProfile(context, forceRefresh: true);

          if (newPhotoUrl != null && newPhotoUrl.isNotEmpty && profileData.value != null) {
            if (profileData.value!.profilePhoto == null || profileData.value!.profilePhoto!.isEmpty) {
              profileData.value!.profilePhoto = newPhotoUrl;
            }
            if (profileData.value!.logo == null || profileData.value!.logo!.isEmpty) {
              profileData.value!.logo = newPhotoUrl;
            }
          }
          profileData.refresh();
          update();

          if (Get.isRegistered<HomeController>()) {
            final homeCtrl = Get.find<HomeController>();
            final photo = profileData.value?.profilePhoto ?? profileData.value?.logo ?? newPhotoUrl;
            if (homeCtrl.homeData.value?.user != null && photo != null && photo.isNotEmpty) {
              homeCtrl.homeData.value!.user!.profilePhoto = photo;
              homeCtrl.homeData.refresh();
            }
            homeCtrl.fetchHomeData(forceRefresh: true);
          }

          return true;
        } else {
          Helpers.hideLoader(loader);
          showSnackBar(jsonResponse['message'] ?? "Failed to update profile", false);
        }
      } else {
        Helpers.hideLoader(loader);
        showSnackBar("Failed to update profile", false);
      }
    } catch (e) {
      Helpers.hideLoader(loader);
      debugPrint("Error updating profile: $e");
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> deactivateAccount({
    required BuildContext context,
    required bool deletePermanently,
  }) async {
    isLoading.value = true;
    try {
      final response = await Repositories().postApi(
        context: context,
        url: "${ApiUrls.apiBaseUrl}/donor/deactivate",
        mapData: {
          "deletePermanently": deletePermanently,
        },
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          String msg = jsonResponse['message'] ?? "Account deleted successfully";
          showSnackBar(msg, true);
          await ManageTokens.clearUserTokens();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isProfileComplete');
          await prefs.remove('role');
          Get.offAllNamed(MyRouters.loginScreen);
          return true;
        } else {
          showSnackBar(jsonResponse['message'] ?? "Failed to delete account", false);
        }
      }
    } catch (e) {
      debugPrint("Error deactivating account: $e");
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> raiseSupportTicket({
    required BuildContext context,
    required String subject,
    required String message,
  }) async {
    isLoading.value = true;
    try {
      final response = await Repositories().postApi(
        context: context,
        url: "${ApiUrls.apiBaseUrl}/donor/help-support",
        mapData: {
          "subject": subject,
          "message": message,
        },
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          await fetchTicketsList(context);
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error raising ticket: $e");
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> fetchTicketsList(BuildContext context) async {
    isTicketsLoading.value = true;
    try {
      final response = await Repositories().getApi(
        context: null,
        url: "${ApiUrls.apiBaseUrl}/donor/help-support",
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        var model = SupportTicketModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          ticketsList.value = model.data!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching tickets list: $e");
    } finally {
      isTicketsLoading.value = false;
    }
  }

  Future<void> fetchCouponsList() async {
    isCouponsLoading.value = true;
    try {
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.couponsUrl,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        var model = CouponModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          couponsList.value = model.data!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching coupons: $e");
    } finally {
      isCouponsLoading.value = false;
    }
  }

  Future<bool> claimCoupon(BuildContext context, String code) async {
    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.claimCouponUrl,
        mapData: {
          "code": code,
        },
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Coupon claimed successfully!", true);
          fetchCouponsList();
          return true;
        } else {
          showSnackBar(jsonResponse['message'] ?? "Failed to claim coupon.", false);
        }
      }
    } catch (e) {
      debugPrint("Error claiming coupon: $e");
      showSnackBar("An unexpected error occurred.", false);
    }
    return false;
  }

  Future<bool> donateWithWallet(BuildContext context, String campaignId, double amount, {bool isNgo = false}) async {
    try {
      final mapData = isNgo 
        ? {
            "ngoId": campaignId,
            "amount": amount,
          }
        : {
            "campaignId": campaignId,
            "amount": amount,
          };

      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.donateUrl,
        mapData: mapData,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        final status = jsonResponse['status'];
        final isSuccess = status == true ||
            status == 200 ||
            status == "200" ||
            status == "true" ||
            status == "success" ||
            jsonResponse['success'] == true ||
            jsonResponse['statusCode'] == 200 ||
            (jsonResponse['message'] != null &&
                jsonResponse['message'].toString().toLowerCase().contains('success'));

        if (isSuccess) {
          showSnackBar(jsonResponse['message'] ?? "Donation successful!", true);
          if (jsonResponse['data'] != null && jsonResponse['data'] is Map<String, dynamic>) {
            try {
              profileData.value = ProfileData.fromJson(jsonResponse['data']);
            } catch (_) {}
          }
          await fetchProfile(context, forceRefresh: true);
          if (Get.isRegistered<WalletController>()) {
            await Get.find<WalletController>().fetchWalletData(forceRefresh: true);
          }
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData(forceRefresh: true);
          }
          return true;
        } else {
          showSnackBar(jsonResponse['message'] ?? "Donation failed.", false);
        }
      }
    } catch (e) {
      debugPrint("Error making donation: $e");
      showSnackBar("An unexpected error occurred during donation.", false);
    }
    return false;
  }

  Future<bool> topupWallet(BuildContext context, double amount) async {
    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.topupUrl,
        mapData: {
          "amount": amount,
        },
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        final status = jsonResponse['status'];
        final isSuccess = status == true ||
            status == 200 ||
            status == "200" ||
            status == "true" ||
            status == "success" ||
            jsonResponse['success'] == true ||
            jsonResponse['statusCode'] == 200 ||
            (jsonResponse['message'] != null &&
                jsonResponse['message'].toString().toLowerCase().contains('success'));

        if (isSuccess) {
          showSnackBar(jsonResponse['message'] ?? "Wallet topped up successfully!", true);
          dynamic respData = jsonResponse['data'] ?? jsonResponse;
          double? updatedBalance;
          if (respData != null && respData is Map<String, dynamic>) {
            final rawBal = respData['walletBalance'] ??
                respData['wallet_balance'] ??
                respData['balance'] ??
                (respData['user'] is Map ? (respData['user']['walletBalance'] ?? respData['user']['balance']) : null);
            if (rawBal is num) {
              updatedBalance = rawBal.toDouble();
            } else if (rawBal != null) {
              updatedBalance = double.tryParse(rawBal.toString());
            }

            try {
              ProfileData updated = ProfileData.fromJson(respData);
              if (updated.walletBalance != null && updated.walletBalance! > 0) {
                profileData.value = updated;
              }
            } catch (e) {
              debugPrint("Error parsing topup response: $e");
            }
          }

          if (updatedBalance != null && updatedBalance > 0) {
            if (profileData.value != null) {
              profileData.value!.walletBalance = updatedBalance;
              profileData.refresh();
            }
            if (Get.isRegistered<WalletController>()) {
              Get.find<WalletController>().walletBalance.value = updatedBalance;
            }
          } else {
            // Optimistically update wallet balance so it reflects immediately
            final currentBal = (Get.isRegistered<WalletController>() && Get.find<WalletController>().walletBalance.value > 0)
                ? Get.find<WalletController>().walletBalance.value
                : (profileData.value?.walletBalance ?? 0.0);
            final newBal = currentBal + amount;
            if (profileData.value != null) {
              profileData.value!.walletBalance = newBal;
              profileData.refresh();
            }
            if (Get.isRegistered<WalletController>()) {
              Get.find<WalletController>().walletBalance.value = newBal;
            }
          }

          final walletCtrl = Get.isRegistered<WalletController>()
              ? Get.find<WalletController>()
              : Get.put(WalletController());
          await walletCtrl.fetchWalletData(forceRefresh: true);
          await fetchProfile(context, forceRefresh: true);

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData(forceRefresh: true);
          }
          return true;
        } else {
          showSnackBar(jsonResponse['message'] ?? "Top up failed.", false);
        }
      }
    } catch (e) {
      debugPrint("Error topping up wallet: $e");
      showSnackBar("An unexpected error occurred during top up.", false);
    }
    return false;
  }

  Future<void> fetchReferralData() async {
    isReferralLoading.value = true;
    try {
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.referralsUrl,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        var model = ReferralModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          referralData.value = model.data!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching referral data: $e");
    } finally {
      isReferralLoading.value = false;
    }
  }

  Future<void> fetchMyCampaigns() async {
    isMyCampaignsLoading.value = true;
    try {
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.myCampaignsUrl,
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        var model = MyCampaignsModel.fromJson(jsonResponse);
        if (model.status == true) {
          myCampaignsData.value = model;
        }
      }
    } catch (e) {
      debugPrint("Error fetching my campaigns: $e");
    } finally {
      isMyCampaignsLoading.value = false;
    }
  }
}
