// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../BusinessFlowScreen/Screen/BusinessDetailsScreen/business_details_screen.dart';
// import '../BusinessFlowScreen/Screen/business_bottom_nav_screen.dart';
// import '../Model/social_login_model.dart';
// import '../TokenManager/token_manager.dart';
// import '../UserFlowScreen/create_profile_screen.dart';
// import '../UserFlowScreen/user_bottom_nav_screen.dart';
// import '../Utilities/api_constant.dart';
// import '../Utilities/helper.dart';
//
// class SocialLoginRepo {
//   static Future<SocialLoginModel> socialLoginRepo({
//     required String googleToken,
//     required String userType,
//     required BuildContext context,
//   }) async {
//     OverlayEntry loader = Helpers.overlayLoader(context);
//     Overlay.of(context).insert(loader);
//
//     try {
//       final map = <String, dynamic>{
//         'google_token': googleToken,
//         'user_type': userType,
//       };
//
//       print("Map Data ----: $map");
//
//       final response = await http.post(
//         Uri.parse(ApiUrls.googleLoginUrl),
//         body: jsonEncode(map),
//         headers: await ManageTokens.getHttpHeadersWithToken(),
//       );
//
//       log("OTP Response Body: ${response.body}");
//
//       Helpers.hideLoader(loader);
//
//       final socialLoginModel =
//       SocialLoginModel.fromJson(jsonDecode(response.body));
//
//       if (socialLoginModel.status == true &&
//           socialLoginModel.data != null ) {
//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString(
//           'loginUserID',
//           socialLoginModel.data!.id.toString(),
//         );
//         prefs.setString('userToken', socialLoginModel.token.toString());
//         prefs.setString('role', socialLoginModel.data!.userType.toString());
//
//         final cookie = response.headers['set-cookie'] ?? "";
//         final token = socialLoginModel.token ?? '';
//
//         await ManageTokens.setUserTokens(
//           cookie: cookie,
//           bToken: token,
//         );
//
//         print("Status----: ${ socialLoginModel.data?.isProfileComplete}");
//         print("Role----: ${socialLoginModel.data?.userType}");
//
//         socialLoginModel.data?.userType == "business"
//             ? socialLoginModel.data?.isProfileComplete == "true"
//             ? Get.offAll(() => const BusinessBottomNavScreen())
//             : Get.off(BusinessDetailsScreen())
//             : socialLoginModel.data?.isProfileComplete == "true"
//             ? Get.offAll(() => const UserBottomNavScreen())
//             : Get.off(CreateYourProfileScreen());
//         // ? Get.to(() => const BusinessDetailsScreen())
//         // : Get.to(() => const CreateYourProfileScreen());
//       } else if (socialLoginModel.message == "Email already taken by another role.") {
//         GoogleSignIn().signOut();
//         showSnackBar(socialLoginModel.message, false);
//       }
//       else {
//         showSnackBar(socialLoginModel.message, false);
//       }
//
//       return socialLoginModel;
//     } catch (e) {
//       Helpers.hideLoader(loader);
//       throw Exception("OTP Verification Failed: $e");
//     }
//   }
// }
//
//
// class AppleLoginRepo {
//   static Future<SocialLoginModel> appleLoginRepo({
//     required String googleToken,
//     required String userType,
//     required BuildContext context,
//     String? fcmToken,
//     String? appleFirstName,
//     String? appleLastName,
//   }) async {
//     OverlayEntry loader = Helpers.overlayLoader(context);
//     Overlay.of(context).insert(loader);
//
//     try {
//       final map = <String, dynamic>{
//         'access_token': googleToken,
//         'user_type': userType,
//         'fcm_token': fcmToken ?? '',
//         'apple_first_name': appleFirstName ?? '',
//         'apple_last_name': appleLastName ?? '',
//       };
//
//       log("Map Data ----: $map");
//
//       final response = await http.post(
//         Uri.parse(ApiUrls.appleLoginUrl),
//         body: jsonEncode(map),
//         headers: await ManageTokens.getHttpHeadersWithToken(),
//       );
//
//       log("OTP Response Body: ${response.body}");
//
//       Helpers.hideLoader(loader);
//
//       final socialLoginModel =
//       SocialLoginModel.fromJson(jsonDecode(response.body));
//
//       if (socialLoginModel.status == true &&
//           socialLoginModel.data != null ) {
//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString(
//           'loginUserID',
//           socialLoginModel.data!.id.toString(),
//         );
//         prefs.setString('userToken', socialLoginModel.token.toString());
//         prefs.setString('role', socialLoginModel.data!.userType.toString());
//
//         final cookie = response.headers['set-cookie'] ?? "";
//         final token = socialLoginModel.token ?? '';
//
//         await ManageTokens.setUserTokens(
//           cookie: cookie,
//           bToken: token,
//         );
//
//         log("Status----: ${ socialLoginModel.data?.isProfileComplete}");
//         log("Role----: ${socialLoginModel.data?.userType}");
//
//         socialLoginModel.data?.userType == "business"
//             ? socialLoginModel.data?.isProfileComplete == "true"
//             ? Get.offAll(() => const BusinessBottomNavScreen())
//             : Get.off(BusinessDetailsScreen())
//             : socialLoginModel.data?.isProfileComplete == "true"
//             ? Get.offAll(() => const UserBottomNavScreen())
//             : Get.off(CreateYourProfileScreen());
//         // ? Get.to(() => const BusinessDetailsScreen())
//         // : Get.to(() => const CreateYourProfileScreen());
//       } else if (socialLoginModel.message == "Email already taken by another role.") {
//         GoogleSignIn().signOut();
//         showSnackBar(socialLoginModel.message, false);
//       }
//       else {
//         showSnackBar(socialLoginModel.message, false);
//       }
//
//       return socialLoginModel;
//     } catch (e) {
//       Helpers.hideLoader(loader);
//       throw Exception("OTP Verification Failed: $e");
//     }
//   }
// }
//
