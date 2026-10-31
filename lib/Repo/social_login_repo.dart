import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../Model/social_login_model.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class SocialLoginRepo {
  final Repositories _repositories = Repositories();

  Future<SocialLoginModel?> googleLoginApi({
    BuildContext? context,
    required String idToken,
    String? email,
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    bool showResponse = true,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'idToken': idToken,
        'email': email ?? '',
        'displayName': displayName ?? '',
        'photoUrl': photoUrl ?? '',
        'fcmToken': fcmToken ?? '',
      };

      log("Google Login Payload: $map");

      final response = await _repositories.postApi(
        context: context,
        url: ApiUrls.googleLoginUrl,
        mapData: map,
        showResponse: showResponse,
      );

      if (response != null) {
        final dynamic jsonResponse = jsonDecode(response);
        if (jsonResponse is Map<String, dynamic>) {
          return SocialLoginModel.fromJson(jsonResponse);
        }
      }
      return null;
    } catch (e) {
      log("Google Login API Exception: $e");
      return null;
    }
  }

  Future<SocialLoginModel?> appleLoginApi({
    BuildContext? context,
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? firstName,
    String? lastName,
    bool showResponse = true,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'email': email ?? '',
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
      };

      log("Apple Login Payload: $map");

      final response = await _repositories.postApi(
        context: context,
        url: ApiUrls.appleLoginUrl,
        mapData: map,
        showResponse: showResponse,
      );

      if (response != null) {
        final dynamic jsonResponse = jsonDecode(response);
        if (jsonResponse is Map<String, dynamic>) {
          return SocialLoginModel.fromJson(jsonResponse);
        }
      }
      return null;
    } catch (e) {
      log("Apple Login API Exception: $e");
      return null;
    }
  }
}
