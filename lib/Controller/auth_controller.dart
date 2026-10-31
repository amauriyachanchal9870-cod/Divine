import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Model/login_model.dart';
import '../Model/verify_otp_model.dart';
import '../Model/profile_setup_model.dart';
import '../Model/master_settings_model.dart';
import '../Model/social_login_model.dart';
import '../Repo/common_repo.dart';
import '../Repo/social_login_repo.dart';
import '../Routes/my_routes.dart';
import '../Screens/auth/otp_verification_screen.dart';
import '../Token Manager/token_manager.dart';
import '../Services/notification_service.dart';
import '../Services/auth_navigation_helper.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';

class AuthController extends GetxController {
  bool isLoading = false;
  bool isSocialLoading = false;
  String activeSocialProvider = '';
  MasterSettingsData? masterSettings;
  final SocialLoginRepo _socialLoginRepo = SocialLoginRepo();
  String? verifiedPhone;
  String? googleEmail;
  bool isGoogleSignIn = false;

  Future<bool> isGoogleUser() async {
    if (isGoogleSignIn) return true;
    final prefs = await SharedPreferences.getInstance();
    isGoogleSignIn = prefs.getBool('isGoogleSignIn') ?? false;
    return isGoogleSignIn;
  }

  Future<String> getGoogleEmail() async {
    if (googleEmail != null && googleEmail!.trim().isNotEmpty) {
      return googleEmail!.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('googleEmail') ?? '';
    if (saved.trim().isNotEmpty) {
      googleEmail = saved.trim();
      return googleEmail!;
    }
    return '';
  }

  Future<String> getVerifiedPhone() async {
    if (verifiedPhone != null && verifiedPhone!.trim().isNotEmpty) {
      return verifiedPhone!.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('userPhone') ?? prefs.getString('verifiedMobile') ?? '';
    if (saved.trim().isNotEmpty) {
      verifiedPhone = saved.trim();
      return verifiedPhone!;
    }
    return '';
  }

  Future<void> fetchMasterSettings() async {
    try {
      final response = await Repositories().getApi(
        context: null,
        url: ApiUrls.masterSettingsUrl,
        showResponse: false,
      );
      if (response != null) {
        var jsonResponse = jsonDecode(response);
        MasterSettingsModel model = MasterSettingsModel.fromJson(jsonResponse);
        if (model.status == true && model.data != null) {
          masterSettings = model.data;
          update();
        }
      }
    } catch (e) {
      debugPrint("Error fetching master settings: $e");
    }
  }

  Future<void> loginUser(BuildContext context, String phone) async {
    isLoading = true;
    verifiedPhone = phone;
    update();

    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.loginUrl,
        mapData: {"phone": phone},
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        LoginModel loginModel = LoginModel.fromJson(jsonResponse);

        if (loginModel.status == true) {
          showSnackBar(loginModel.message ?? "OTP sent successfully", true);

          // If isUserExist is true, it means user already registered, we pass isLogin = true
          // If isUserExist is false, it means new user, we pass isLogin = false
          bool isUserExist = loginModel.isUserExist ?? false;

          Get.bottomSheet(
            OTPVerificationScreen(
              phone: phone,
              otp: loginModel.otp,
              isLogin: isUserExist,
            ),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            enterBottomSheetDuration: const Duration(milliseconds: 250),
            exitBottomSheetDuration: const Duration(milliseconds: 200),
          );
        } else {
          showSnackBar(loginModel.message ?? "Something went wrong", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> resendOtp(BuildContext context, String phone) async {
    isLoading = true;
    update();

    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.resendOtpUrl,
        mapData: {"phone": phone},
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        LoginModel loginModel = LoginModel.fromJson(jsonResponse);

        if (loginModel.status == true) {
          showSnackBar(loginModel.message ?? "OTP resent successfully", true);
          return true;
        } else {
          showSnackBar(loginModel.message ?? "Something went wrong", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
    return false;
  }

  Future<void> verifyOtp(BuildContext context, String phone, String otp) async {
    isLoading = true;
    update();

    try {
      int? httpStatusCode;
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.verifyOtpUrl,
        mapData: {
          "phone": phone,
          "otp": otp,
        },
        withStatus: (status, res) {
          httpStatusCode = status;
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        VerifyOtpModel verifyModel = VerifyOtpModel.fromJson(jsonResponse);

        final bool isSuccess = verifyModel.status == true ||
            httpStatusCode == 200 ||
            jsonResponse['status'] == 200 ||
            jsonResponse['status'] == '200' ||
            jsonResponse['statusCode'] == 200 ||
            jsonResponse['statusCode'] == '200' ||
            jsonResponse['status_code'] == 200 ||
            jsonResponse['status_code'] == '200';

        if (isSuccess) {
          if (verifyModel.token != null && verifyModel.token!.isNotEmpty) {
            await ManageTokens.setUserTokens(
              bToken: verifyModel.token!,
              cookie: "",
            );
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', verifyModel.isProfileComplete ?? false);
          await prefs.setBool('isFirstTime', false);
          if (verifyModel.isProfileComplete == false) {
            await ManageTokens.setOnboardingStartTime();
          } else {
            await ManageTokens.clearOnboardingStartTime();
          }

          if (phone.isNotEmpty) {
            verifiedPhone = phone;
            await prefs.setString('userPhone', phone);
            String digits = phone.replaceAll(RegExp(r'\D'), '');
            if (digits.length >= 10) {
              await prefs.setString('verifiedMobile', digits.substring(digits.length - 10));
            } else if (digits.isNotEmpty) {
              await prefs.setString('verifiedMobile', digits);
            }
          } else if (verifyModel.data?.phone != null && verifyModel.data!.phone!.isNotEmpty) {
            verifiedPhone = verifyModel.data!.phone!;
            await prefs.setString('userPhone', verifyModel.data!.phone!);
            String digits = verifyModel.data!.phone!.replaceAll(RegExp(r'\D'), '');
            if (digits.length >= 10) {
              await prefs.setString('verifiedMobile', digits.substring(digits.length - 10));
            } else if (digits.isNotEmpty) {
              await prefs.setString('verifiedMobile', digits);
            }
          }

          String? userRole = verifyModel.data?.role;
          if (userRole == null || userRole.isEmpty) {
            userRole = jsonResponse['role']?.toString() ??
                (jsonResponse['data'] is Map ? jsonResponse['data']['role']?.toString() : null) ??
                prefs.getString('role');
          }
          if (userRole != null && userRole.isNotEmpty) {
            await prefs.setString('role', userRole);
          } else {
            await prefs.remove('role');
          }

          isGoogleSignIn = false;
          googleEmail = null;
          await prefs.setBool('isGoogleSignIn', false);
          await prefs.remove('googleEmail');

          // Register device token with backend
          await NotificationService.instance.registerDeviceTokenWithBackend();

          showSnackBar(verifyModel.message ?? "OTP verified successfully", true);

          final dynamic verificationStatus = verifyModel.verificationStatus ??
              verifyModel.data?.verificationStatus ??
              (verifyModel.isVerified == true ? 'Verified' : 'Pending');

          final String? rejectionReason = verifyModel.rejectionReason ??
              verifyModel.data?.rejectionReason ??
              jsonResponse['rejectionReason']?.toString() ??
              jsonResponse['rejection_reason']?.toString();

          await AuthNavigationHelper.navigateBasedOnStatus(
            verificationStatus: verificationStatus,
            isProfileComplete: verifyModel.isProfileComplete,
            role: userRole,
            rejectionReason: rejectionReason,
            customMessage: verifyModel.message,
          );
        } else {
          showSnackBar(verifyModel.message ?? "Invalid OTP", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (isLoading || isSocialLoading) return;
    isSocialLoading = true;
    activeSocialProvider = 'google';
    update();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut().catchError((_) => null);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled account selection
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String? idToken =
          await userCredential.user?.getIdToken() ?? googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        showSnackBar("Failed to retrieve Google authentication token", false);
        return;
      }

      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getDeviceToken();
      } catch (e) {
        log("Error retrieving FCM token for Google login: $e");
      }

      final String gEmail = userCredential.user?.email ?? googleUser.email;

      final SocialLoginModel? socialModel = await _socialLoginRepo.googleLoginApi(
        context: context,
        idToken: idToken,
        email: gEmail,
        displayName: userCredential.user?.displayName ?? googleUser.displayName,
        photoUrl: userCredential.user?.photoURL ?? googleUser.photoUrl,
        fcmToken: fcmToken ?? '',
      );

      if (socialModel != null && socialModel.status == true) {
        if (socialModel.token != null && socialModel.token!.isNotEmpty) {
          await ManageTokens.setUserTokens(
            bToken: socialModel.token!,
            cookie: "",
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGoogleSignIn', true);
        isGoogleSignIn = true;

        final String resolvedGoogleEmail = gEmail.trim().isNotEmpty
            ? gEmail.trim()
            : (socialModel.data?.email != null && socialModel.data!.email!.trim().isNotEmpty
                ? socialModel.data!.email!.trim()
                : '');

        if (resolvedGoogleEmail.isNotEmpty) {
          googleEmail = resolvedGoogleEmail;
          await prefs.setString('googleEmail', resolvedGoogleEmail);
        }

        await prefs.setBool('isProfileComplete', socialModel.isProfileComplete ?? false);
        await prefs.setBool('isFirstTime', false);
        if (socialModel.isProfileComplete == false) {
          await ManageTokens.setOnboardingStartTime();
        } else {
          await ManageTokens.clearOnboardingStartTime();
        }

        bool isVerified = socialModel.isVerified ?? socialModel.data?.isVerified ?? false;
        await prefs.setBool('verified', isVerified);

        if (socialModel.data?.phone != null && socialModel.data!.phone!.isNotEmpty) {
          await prefs.setString('userPhone', socialModel.data!.phone!);
        }
        if (socialModel.data?.email != null && socialModel.data!.email!.isNotEmpty) {
          await prefs.setString('userEmail', socialModel.data!.email!);
        }
        if (socialModel.data?.id != null && socialModel.data!.id!.isNotEmpty) {
          await prefs.setString('loginUserID', socialModel.data!.id!);
        }

        String? userRole = socialModel.data?.role;
        if (userRole != null && userRole.isNotEmpty) {
          await prefs.setString('role', userRole);
        }

        // Register device token with backend
        await NotificationService.instance.registerDeviceTokenWithBackend();

        showSnackBar(socialModel.message ?? "Google Sign-In successful", true);

        final dynamic verificationStatus = socialModel.verificationStatus ??
            socialModel.data?.verificationStatus ??
            (isVerified ? 'Verified' : 'Pending');

        await AuthNavigationHelper.navigateBasedOnStatus(
          verificationStatus: verificationStatus,
          isProfileComplete: socialModel.isProfileComplete,
          role: userRole,
          customMessage: socialModel.message,
        );
      } else {
        showSnackBar(socialModel?.message ?? "Google Sign-In failed. Please try again.", false);
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Exception: ${e.code} - ${e.message}");
      showSnackBar(e.message ?? "Authentication failed", false);
    } catch (e) {
      log("Google Sign-In Error: $e");
      showSnackBar("Google Sign-In failed: ${e.toString()}", false);
    } finally {
      isSocialLoading = false;
      activeSocialProvider = '';
      update();
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    if (isLoading || isSocialLoading) return;
    isSocialLoading = true;
    activeSocialProvider = 'apple';
    update();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: null,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final String identityToken = appleCredential.identityToken ?? '';
      final String authorizationCode = appleCredential.authorizationCode;

      if (identityToken.isEmpty) {
        showSnackBar("Failed to retrieve Apple authentication token", false);
        return;
      }

      String? email = appleCredential.email ?? userCredential.user?.email;
      String? firstName = appleCredential.givenName;
      String? lastName = appleCredential.familyName;

      final SocialLoginModel? socialModel = await _socialLoginRepo.appleLoginApi(
        context: context,
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      if (socialModel != null && socialModel.status == true) {
        showSnackBar(socialModel.message ?? "Apple Sign-In successful", true);

        if (socialModel.token != null && socialModel.token!.isNotEmpty) {
          await ManageTokens.setUserTokens(
            bToken: socialModel.token!,
            cookie: "",
          );
        }

        final prefs = await SharedPreferences.getInstance();
        isGoogleSignIn = false;
        googleEmail = null;
        await prefs.setBool('isGoogleSignIn', false);
        await prefs.remove('googleEmail');
        await prefs.setBool('isProfileComplete', socialModel.isProfileComplete ?? false);
        await prefs.setBool('isFirstTime', false);
        if (socialModel.isProfileComplete == false) {
          await ManageTokens.setOnboardingStartTime();
        } else {
          await ManageTokens.clearOnboardingStartTime();
        }

        if (socialModel.data?.phone != null && socialModel.data!.phone!.isNotEmpty) {
          await prefs.setString('userPhone', socialModel.data!.phone!);
        }
        if (socialModel.data?.email != null && socialModel.data!.email!.isNotEmpty) {
          await prefs.setString('userEmail', socialModel.data!.email!);
        }
        if (socialModel.data?.id != null && socialModel.data!.id!.isNotEmpty) {
          await prefs.setString('loginUserID', socialModel.data!.id!);
        }

        String? userRole = socialModel.data?.role;
        if (userRole != null && userRole.isNotEmpty) {
          await prefs.setString('role', userRole);
        }

        // Register device token with backend
        NotificationService.instance.registerDeviceTokenWithBackend();

        final dynamic verificationStatus = socialModel.verificationStatus ??
            socialModel.data?.verificationStatus ??
            (socialModel.isVerified == true ? 'Verified' : 'Pending');

        await AuthNavigationHelper.navigateBasedOnStatus(
          verificationStatus: verificationStatus,
          isProfileComplete: socialModel.isProfileComplete,
          role: userRole,
          customMessage: socialModel.message,
        );
      } else {
        showSnackBar(socialModel?.message ?? "Apple Sign-In failed. Please try again.", false);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      log("Sign in with Apple authorization error: ${e.code} - ${e.message}");
      if (e.code != AuthorizationErrorCode.canceled) {
        showSnackBar(e.message, false);
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Exception: ${e.code} - ${e.message}");
      showSnackBar(e.message ?? "Authentication failed", false);
    } catch (e) {
      log("Apple Sign-In Error: $e");
      showSnackBar("Apple Sign-In failed: ${e.toString()}", false);
    } finally {
      isSocialLoading = false;
      activeSocialProvider = '';
      update();
    }
  }

  Future<void> profileSetup(BuildContext context, String name, String email, String gender, String profilePhoto) async {
    isLoading = true;
    update();

    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.profileSetupUrl,
        mapData: {
          "name": name,
          "email": email,
          "gender": gender,
          "profilePhoto": profilePhoto,
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        ProfileSetupModel profileModel = ProfileSetupModel.fromJson(jsonResponse);

        if (profileModel.status == true) {
          showSnackBar(profileModel.message ?? "Profile set up successfully", true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', true);
          await ManageTokens.clearOnboardingStartTime();
          await prefs.setBool('isFirstTime', false);
          await prefs.setString('role', 'donor');
          // Register device token with backend
          NotificationService.instance.registerDeviceTokenWithBackend();
          Get.toNamed(MyRouters.successScreen);
        } else {
          showSnackBar(profileModel.message ?? "Something went wrong", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoading = true;
    update();

    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.logoutUrl,
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Logged out successfully", true);
          
          // Remove device token from backend
          await NotificationService.instance.removeDeviceTokenFromBackend();

          // Sign out from third party social providers and clear all session data
          await ManageTokens.clearAllAuthSession();
          
          // Navigate back to login screen
          Get.offAllNamed(MyRouters.loginScreen);
        } else {
          showSnackBar(jsonResponse['message'] ?? "Logout failed", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<String?> uploadFile(File file) async {
    if (!file.existsSync()) return null;

    print("📸 [AuthController.uploadFile] Starting upload: ${file.path} (${file.lengthSync()} bytes)");

    const imgbbKey = ApiUrls.imgbbApiKey;
    if (imgbbKey == 'YOUR_IMGBB_API_KEY_HERE' || imgbbKey.isEmpty) {
      print("⚠️ [AuthController.uploadFile] ImgBB API key not set in ApiUrls.imgbbApiKey!");
    }

    final bool isPdf = file.path.toLowerCase().endsWith('.pdf');

    // Server 1: ImgBB base64 — permanent URL, works in India (no ISP blocking)
    if (!isPdf && imgbbKey != 'YOUR_IMGBB_API_KEY_HERE' && imgbbKey.isNotEmpty) {
      try {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final response = await http.post(
          Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbKey'),
          body: {'image': base64Image},
        ).timeout(const Duration(seconds: 30));
        print("✅ [ImgBB] Status: ${response.statusCode} | Body: ${response.body}");
        if (response.statusCode == 200) {
          final jsonResp = jsonDecode(response.body);
          if (jsonResp['success'] == true) {
            final url = jsonResp['data']['display_url']?.toString()
                ?? jsonResp['data']['url']?.toString()
                ?? '';
            if (url.isNotEmpty) {
              print("✅ [ImgBB] Upload SUCCESS: $url");
              return url;
            }
          }
        }
      } catch (e, s) {
        print("❌ [ImgBB] EXCEPTION: $e\n$s");
      }
    }

    // Server 2: Catbox — permanent URL (may be blocked on Indian mobile IPs)
    try {
      final client = http.Client();
      try {
        final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
        request.fields['reqtype'] = 'fileupload';
        request.files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 45));
        final responseData = await streamedResponse.stream.bytesToString();
        print("✅ [Catbox] Status: ${streamedResponse.statusCode} | Body: $responseData");
        if (streamedResponse.statusCode == 200) {
          final url = responseData.trim();
          if (url.startsWith('https://files.catbox.moe/')) {
            print("✅ [Catbox] Upload SUCCESS: $url");
            return url;
          }
        }
      } finally {
        client.close();
      }
    } catch (e, s) {
      print("❌ [Catbox] EXCEPTION: $e\n$s");
    }

    // Server 3: ImgBB multipart retry
    if (!isPdf && imgbbKey != 'YOUR_IMGBB_API_KEY_HERE' && imgbbKey.isNotEmpty) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbKey'),
        );
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
        final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
        final responseData = await streamedResponse.stream.bytesToString();
        print("✅ [ImgBB-retry] Status: ${streamedResponse.statusCode} | Body: $responseData");
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
        }
      } catch (e, s) {
        print("❌ [ImgBB-retry] EXCEPTION: $e\n$s");
      }
    }

    print("❌ [AuthController.uploadFile] ALL servers failed.");
    return null;
  }

  Future<String?> _uploadFileToCatbox(dynamic file) async {
    if (file == null) return null;
    if (file is String) return file;
    if (file is File) {
      if (!file.existsSync()) return null;
      return await uploadFile(file);
    }
    return null;
  }

  Future<void> registerDonor({
    required BuildContext context,
    required String name,
    required String email,
    required String gender,
    required File? profilePhoto,
  }) async {
    isLoading = true;
    update();

    try {
      final String? photoUrl = await _uploadFileToCatbox(profilePhoto);

      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.registerUrl,
        mapData: {
          "role": "donor",
          "name": name,
          "email": email,
          "gender": gender,
          "profilePhoto": photoUrl ?? "",
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', true);
          await ManageTokens.clearOnboardingStartTime();
          await prefs.setBool('isFirstTime', false);
          await prefs.setString('role', 'donor');
          Get.toNamed(MyRouters.successScreen);
        } else {
          showSnackBar(jsonResponse['message'] ?? "Something went wrong", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<dynamic> _processFileUploads(dynamic value) async {
    if (value is File) {
      return await uploadFile(value) ?? "";
    } else if (value is List) {
      List<dynamic> newList = [];
      for (var item in value) {
        newList.add(await _processFileUploads(item));
      }
      return newList;
    } else if (value is Map<String, dynamic>) {
      Map<String, dynamic> newMap = {};
      for (var entry in value.entries) {
        newMap[entry.key] = await _processFileUploads(entry.value);
      }
      return newMap;
    }
    return value;
  }

  Future<void> registerNgo({
    required BuildContext context,
    required Map<String, dynamic> ngoData,
    required String bankAccountHolder,
    required String bankName,
    required String bankBranch,
    required String bankAccountNumber,
    required String bankIFSC,
    dynamic cancelledChequeDoc,
  }) async {
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> processedData = await _processFileUploads(ngoData);

      String role = processedData['role'] ?? "ngo";
      String orgType = processedData['organizationType'] ?? (role == "corporate" ? "corporate" : "Non-Profit");

      final Map<String, dynamic> mapData = {
        "role": role,
        "organizationType": orgType,
        "phone": processedData['phone'] ?? "",
        "organizationName": processedData['organizationName'] ?? "",
        "registeredAddress": processedData['registeredAddress'] ?? "",
        "authorizedPerson": processedData['authorizedPerson'] ?? "",
        "designation": processedData['designation'] ?? "",
        "gender": processedData['gender'] ?? "",
        "email": processedData['email'] ?? "",
        "panNumber": processedData['panNumber'] ?? "",
        "tanNumber": processedData['tanNumber'] ?? "",
        "gstNumber": processedData['gstNumber'] ?? "",
        "bankAccountHolder": bankAccountHolder,
        "bankName": bankName,
        "bankBranch": bankBranch,
        "bankAccountNumber": bankAccountNumber,
        "bankIFSC": bankIFSC,
      };

      if (cancelledChequeDoc != null) {
        mapData['cancelledChequeDoc'] = await _processFileUploads(cancelledChequeDoc);
      }

      // Merge all other keys from processedData
      processedData.forEach((key, value) {
        if (!mapData.containsKey(key) && value != null) {
          mapData[key] = value;
        }
      });

      // Ensure profilePhoto & logo are set
      if (processedData['profilePhoto'] != null && processedData['profilePhoto'].toString().isNotEmpty) {
        mapData['profilePhoto'] = processedData['profilePhoto'];
        mapData['logo'] = processedData['profilePhoto'];
      }

      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.registerUrl,
        mapData: mapData,
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? (role == "corporate" ? "Corporate registered successfully" : "NGO registered successfully"), true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstTime', false);
          await ManageTokens.clearOnboardingStartTime();

          if (jsonResponse['token'] != null && jsonResponse['token'].toString().isNotEmpty) {
            await ManageTokens.setUserTokens(
              bToken: jsonResponse['token'].toString(),
              cookie: "",
            );
          }

          final dynamic verificationStatus = jsonResponse['verificationStatus'] ??
              jsonResponse['data']?['verificationStatus'] ??
              (jsonResponse['verified'] == true || jsonResponse['isVerified'] == true ? 'Verified' : 'Pending');
          final bool isComplete = jsonResponse['isProfileComplete'] is bool
              ? jsonResponse['isProfileComplete']
              : (jsonResponse['isProfileComplete']?.toString() == 'true' || true);
          final String? rejectionReason = jsonResponse['rejectionReason']?.toString() ??
              jsonResponse['rejection_reason']?.toString() ??
              (jsonResponse['data'] is Map ? jsonResponse['data']['rejectionReason']?.toString() : null);

          await AuthNavigationHelper.navigateBasedOnStatus(
            verificationStatus: verificationStatus,
            isProfileComplete: isComplete,
            role: role,
            rejectionReason: rejectionReason,
            customMessage: jsonResponse['message'],
          );
        } else {
          showSnackBar(jsonResponse['message'] ?? "Something went wrong", false);
        }
      }
    } catch (e) {
      showSnackBar("Error: ${e.toString()}", false);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> checkEmailAvailability(BuildContext context, String email) async {
    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.registerUrl,
        mapData: {
          "email": email,
          "checkOnly": true,
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == false &&
            (jsonResponse['message']?.toString().toLowerCase().contains('email') == true ||
             jsonResponse['message']?.toString().toLowerCase().contains('already') == true ||
             jsonResponse['message']?.toString().toLowerCase().contains('exist') == true)) {
          showSnackBar(jsonResponse['message'] ?? "Email is already registered with another account", false);
          return false;
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}
