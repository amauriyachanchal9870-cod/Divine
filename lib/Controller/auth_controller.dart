import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/login_model.dart';
import '../Model/verify_otp_model.dart';
import '../Model/profile_setup_model.dart';
import '../Repo/common_repo.dart';
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
import '../Utilities/api_constant.dart';
import '../Utilities/helper.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  Future<void> loginUser(BuildContext context, String phone) async {
    isLoading = true;
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

          Get.toNamed(
            MyRouters.otpVerificationScreen,
            arguments: {
              'isLogin': isUserExist,
              'phone': phone,
              'otp': loginModel.otp,
              // Pass OTP just in case it needs to be pre-filled or used
            },
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

  Future<void> verifyOtp(BuildContext context, String phone, String otp) async {
    isLoading = true;
    update();

    try {
      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.verifyOtpUrl,
        mapData: {
          "phone": phone,
          "otp": otp,
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        VerifyOtpModel verifyModel = VerifyOtpModel.fromJson(jsonResponse);

        if (verifyModel.status == true) {
          showSnackBar(verifyModel.message ?? "OTP verified successfully", true);

          // Save token
          if (verifyModel.token != null) {
            await ManageTokens.setUserTokens(
              bToken: verifyModel.token!,
              cookie: "",
            );
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', verifyModel.isProfileComplete ?? false);
          
          String? userRole = verifyModel.data?.role;
          if (userRole != null && userRole.isNotEmpty) {
            await prefs.setString('role', userRole);
          } else {
            await prefs.remove('role');
          }

          if (verifyModel.isProfileComplete == true) {
            Get.offAllNamed(MyRouters.mainNav);
          } else {
            Get.offAllNamed(MyRouters.roleSelectionScreen);
          }
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
          "profilePhoto": profilePhoto.isEmpty ? "https://randomuser.me/api/portraits/women/44.jpg" : profilePhoto,
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
          await prefs.setString('role', 'donor');
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
          
          // Clear locally stored tokens
          await ManageTokens.clearUserTokens();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isProfileComplete');
          await prefs.remove('role');
          
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
    try {
      final request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
      request.fields['reqtype'] = 'fileupload';
      request.files.add(await http.MultipartFile.fromPath('fileToUpload', file.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final url = responseData.trim();
        print("Uploaded file URL: $url");
        return url;
      }
    } catch (e) {
      print("Error uploading to Catbox: $e");
    }
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
          "profilePhoto": photoUrl ?? "https://randomuser.me/api/portraits/women/44.jpg",
        },
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "Profile set up successfully", true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', true);
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

  Future<void> registerNgo({
    required BuildContext context,
    required Map<String, dynamic> ngoData,
    required String bankAccountHolder,
    required String bankName,
    required String bankBranch,
    required String bankAccountNumber,
    required String bankIFSC,
  }) async {
    isLoading = true;
    update();

    try {
      final String? profilePhotoUrl = await _uploadFileToCatbox(ngoData['profilePhoto']);
      final String? addressCertificateUrl = await _uploadFileToCatbox(ngoData['addressCertificate']);
      final String? panImageUrl = await _uploadFileToCatbox(ngoData['panImage']);
      final String? tanImageUrl = await _uploadFileToCatbox(ngoData['tanImage']);
      final String? gstDocumentUrl = await _uploadFileToCatbox(ngoData['gstDocument']);
      final String? certificate12AUrl = await _uploadFileToCatbox(ngoData['certificate12A']);
      final String? certificate80GUrl = await _uploadFileToCatbox(ngoData['certificate80G']);
      final String? darpanCertificateUrl = await _uploadFileToCatbox(ngoData['darpanCertificate']);
      final String? csr1CertificateUrl = await _uploadFileToCatbox(ngoData['csr1Certificate']);
      final String? fcraCertificateUrl = await _uploadFileToCatbox(ngoData['fcraCertificate']);
      final String? otherRegistrationCertificateUrl = await _uploadFileToCatbox(ngoData['otherRegistrationCertificate']);

      final Map<String, dynamic> mapData = {
        "role": "ngo",
        "phone": ngoData['phone'] ?? "",
        "organizationName": ngoData['organizationName'] ?? "",
        "registeredAddress": ngoData['registeredAddress'] ?? "",
        "authorizedPerson": ngoData['authorizedPerson'] ?? "",
        "designation": ngoData['designation'] ?? "",
        "gender": ngoData['gender'] ?? "",
        "email": ngoData['email'] ?? "",
        "panNumber": ngoData['panNumber'] ?? "",
        "tanNumber": ngoData['tanNumber'] ?? "",
        "gstNumber": ngoData['gstNumber'] ?? "",
        "registration12A": ngoData['registration12A'] ?? "",
        "registration80G": ngoData['registration80G'] ?? "",
        "hasDarpan": ngoData['hasDarpan'] ?? false,
        "darpanNumber": ngoData['darpanNumber'] ?? "",
        "hasCSR1": ngoData['hasCSR1'] ?? false,
        "csr1Number": ngoData['csr1Number'] ?? "",
        "hasFCRA": ngoData['hasFCRA'] ?? false,
        "fcraNumber": ngoData['fcraNumber'] ?? "",
        "hasOtherRegistration": ngoData['hasOtherRegistration'] ?? false,
        "otherRegistrationName": ngoData['otherRegistrationName'] ?? "",
        "bankAccountHolder": bankAccountHolder,
        "bankName": bankName,
        "bankBranch": bankBranch,
        "bankAccountNumber": bankAccountNumber,
        "bankIFSC": bankIFSC,
        
        "profilePhoto": profilePhotoUrl ?? "",
        "addressCertificate": addressCertificateUrl ?? "",
        "panImage": panImageUrl ?? "",
        "tanImage": tanImageUrl ?? "",
        "gstDocument": gstDocumentUrl ?? "",
        "certificate12A": certificate12AUrl ?? "",
        "certificate80G": certificate80GUrl ?? "",
        "darpanCertificate": darpanCertificateUrl ?? "",
        "csr1Certificate": csr1CertificateUrl ?? "",
        "fcraCertificate": fcraCertificateUrl ?? "",
        "otherRegistrationCertificate": otherRegistrationCertificateUrl ?? "",
      };

      final response = await Repositories().postApi(
        context: context,
        url: ApiUrls.registerUrl,
        mapData: mapData,
        showResponse: true,
      );

      if (response != null) {
        var jsonResponse = jsonDecode(response);
        if (jsonResponse['status'] == true) {
          showSnackBar(jsonResponse['message'] ?? "NGO registered successfully", true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isProfileComplete', true);
          await prefs.setString('role', 'ngo');
          Get.offAllNamed(MyRouters.successScreen);
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
}
