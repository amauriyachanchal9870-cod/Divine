import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/profile_model.dart';
import '../Model/support_ticket_model.dart';
import '../Model/coupon_model.dart';
import '../Model/referral_model.dart';
import '../Repo/common_repo.dart';
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';
import 'home_controller.dart';

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

  Future<void> fetchProfile(BuildContext context) async {
    _safeSetLoading(isLoading, true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role');
      String primaryUrl = (role == 'ngo') ? ApiUrls.ngoProfileUrl : ApiUrls.profileUrl;

      dynamic response = await Repositories().getApi(
        context: null,
        url: primaryUrl,
      );

      bool loaded = false;
      if (response != null) {
        var jsonResponse = jsonDecode(response);
        ProfileModel profileModel = ProfileModel.fromJson(jsonResponse);
        if (profileModel.status == true && profileModel.data != null) {
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
          if (profileModel.status == true && profileModel.data != null) {
            profileData.value = profileModel.data;
            loaded = true;
          }
        }
      }

      // Fallback merge from HomeController if certain user fields (phone/name) are still missing
      if (profileData.value != null && Get.isRegistered<HomeController>()) {
        final homeUser = Get.find<HomeController>().homeData.value?.user;
        if (homeUser != null) {
          if (profileData.value!.phone == null || profileData.value!.phone!.isEmpty) {
            profileData.value!.phone = homeUser.phone;
          }
          if (profileData.value!.name == null || profileData.value!.name!.isEmpty) {
            profileData.value!.name = homeUser.name;
          }
          profileData.refresh();
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _safeSetLoading(isLoading, false);
    }
  }

  Future<bool> updateProfile({
    required BuildContext context,
    required Map<String, dynamic> mapData,
  }) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'donor';
      final String url = role == 'ngo' ? ApiUrls.ngoProfileUrl : ApiUrls.profileUrl;

      final response = await Repositories().putApi(
        context: context,
        url: url,
        mapData: mapData,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          if (profileData.value != null) {
            if (mapData.containsKey('name')) {
              profileData.value!.name = mapData['name'];
            }
            if (mapData.containsKey('email')) {
              profileData.value!.email = mapData['email'];
            }
            if (mapData.containsKey('gender')) {
              profileData.value!.gender = mapData['gender'];
            }
            if (mapData.containsKey('organizationName')) {
              profileData.value!.organizationName = mapData['organizationName'];
            }
            if (mapData.containsKey('about')) {
              profileData.value!.impactStats = mapData['about'];
            }
            if (mapData.containsKey('registeredAddress')) {
              profileData.value!.registeredAddress = mapData['registeredAddress'];
            }
            profileData.refresh();
          }
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
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
          await ManageTokens.clearUserTokens();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isProfileComplete');
          await prefs.remove('role');

          Get.offAllNamed(MyRouters.loginScreen);
          return true;
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
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Donation successful!", true);
          if (jsonResponse['data'] != null) {
            profileData.value = ProfileData.fromJson(jsonResponse['data']);
          }
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData();
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
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Wallet topped up successfully!", true);
          if (jsonResponse['data'] != null) {
            profileData.value = ProfileData.fromJson(jsonResponse['data']);
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
}
