import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../Repo/common_repo.dart';
import '../Utilities/api_constant.dart';

class NotificationRepo {
  final Repositories _repositories = Repositories();

  Future<bool> registerDeviceTokenApi({
    BuildContext? context,
    required String deviceToken,
    required String platform,
    String? deviceId,
    bool showResponse = false,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'deviceToken': deviceToken,
        'platform': platform,
        if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      };

      log("Register Device Token Payload: $map");

      final response = await _repositories.postApi(
        context: context,
        url: ApiUrls.deviceTokenUrl,
        mapData: map,
        showResponse: showResponse,
      );

      if (response != null) {
        final dynamic jsonResponse = jsonDecode(response);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse['status'] == true || jsonResponse['success'] == true;
        }
      }
      return false;
    } catch (e) {
      log("Register Device Token Exception: $e");
      return false;
    }
  }

  Future<bool> removeDeviceTokenApi({
    BuildContext? context,
    required String deviceToken,
    bool showResponse = false,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'deviceToken': deviceToken,
      };

      log("Remove Device Token Payload: $map");

      final response = await _repositories.postApi(
        context: context,
        url: ApiUrls.removeDeviceTokenUrl,
        mapData: map,
        showResponse: showResponse,
      );

      if (response != null) {
        final dynamic jsonResponse = jsonDecode(response);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse['status'] == true || jsonResponse['success'] == true;
        }
      }
      return false;
    } catch (e) {
      log("Remove Device Token Exception: $e");
      return false;
    }
  }
}
