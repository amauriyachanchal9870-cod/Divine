import 'dart:developer';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ManageTokens {
  static setUserTokens({
    required String bToken,
    required String cookie,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("bToken", bToken);
    sharedPreferences.setString("cookie", cookie);
    log("Tokens Saved Successfully");
    log("btokenee::::::::$bToken");
    log("cokieee::::::::$cookie");
  }

  static Future<void> clearUserTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("bToken");
    await sharedPreferences.remove("cookie");
    log("Tokens Cleared Successfully");
  }

  static Future<Map<String, String>?> getTokenHeaders() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("bToken") != null && sharedPreferences.getString("cookie") != null) {
      return {
        'Authorization': 'Bearer ${sharedPreferences.getString("bToken").toString().replaceAll('"', '')}',
        'Cookie': sharedPreferences.getString("cookie").toString().replaceAll('"', '')
      };
    }
    return null;
  }

  static Future<Map<String, String>> getHttpHeadersWithToken({bool? isXAuthClient}) async {
    final item = await getTokenHeaders();
    final kk = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
      if(isXAuthClient==true)
      // "X-AUTH-CLIENT": "15e3deef-217f-4bad-9ee7-248c74136ef2",
        "X-AUTH-CLIENT": "cf896ad7-67ac-41fd-81f6-cffccc2a5bd3",
      // "X-AUTH-CLIENT": "ee852136-0e3f-418e-a78c-56dac958845a",
    };
    kk.addAll(item ?? {});
    return kk;
  }
}
