import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Token Manager/token_manager.dart';
import '../Utilities/helper.dart';

class Repositories {
  Future<dynamic> postApi({
    BuildContext? context,
    required String url,
    bool? showMap = false,
    bool? isXAuthClient = false,
    Function(int status, String response)? withStatus,
    bool? showResponse = true,
    Map<String, dynamic>? mapData,
    Color? color,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};

      // if (kDebugMode) {
      log("API Url.....  $url");
      log("API mapData.....  $mapData");
      if (true) {
        log("API headers.....  $headers");
      }
      // }

      http.Response response = await http.post(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      // if (kDebugMode) {
      //   if (showResponse == true) {
      log("API Response Url........  $url");
      log("API Response........  ${response.body}");
      log("API Response Status Code........  ${response.statusCode}");
      log("API Response Reason Phrase........  ${response.reasonPhrase}");
      // }
      // }

      Helpers.hideLoader(loader);

      if (response.statusCode == 200 || response.statusCode == 404 || response.statusCode == 400 || response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      }
      else if (response.statusCode == 401 && response.body == "Unauthorized") {
        // Get.offAll(AccountTypeScreen());
        logOutUser();
        // throw Exception(response.body.toString());
      }
      else {
        // showToast(response.body);
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      // showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      throw Exception(e);
    }
  }

  Future<dynamic> putApi({
    BuildContext? context,
    required String url,
    // bool? showLoader = false,
    bool? showMap = false,
    Function(int status, String response)? withStatus,
    bool? showResponse = true,
    Map<String, dynamic>? mapData,
    Color? color,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};

      if (kDebugMode) {
        log("API Url.....  $url");
        log("API mapData.....  $mapData");
        if (true) {
          log("API headers.....  $headers");
        }
      }

      http.Response response = await http.put(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      if (kDebugMode) {
        if (showResponse == true) {
          log("API Response Url........  $url");
          log("API Response........  ${response.body}");
          log("API Response Status Code........  ${response.statusCode}");
          log("API Response Reason Phrase........  ${response.reasonPhrase}");
        }
      }

      Helpers.hideLoader(loader);

      if (response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        log("WWWWWWWWWWW>>>${response.statusCode.toString()}");
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      }  else if (response.statusCode == 401 && response.body == "Unauthorized") {
        // Get.offAll(AccountTypeScreen());
        logOutUser();
      } else {
        // showToast(response.body);
        return response.body;
      }
    } on SocketException catch (e) {
      log("WWWWWWWWWWW>>>${e.toString()}");
      Helpers.hideLoader(loader);
      //showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      log("WWWWWWWWWWW>>>${e.toString()}");
      Helpers.hideLoader(loader);
      throw Exception(e);
    }
  }

  Future<dynamic> patchApi({
    BuildContext? context,
    required String url,
    // bool? showLoader = false,
    bool? showMap = false,
    Function(int status, String response)? withStatus,
    bool? showResponse = true,
    Map<String, dynamic>? mapData,
    Color? color,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};

      if (kDebugMode) {
        log("API Url.....  $url");
        log("API mapData.....  $mapData");
        if (true) {
          log("API headers.....  $headers");
        }
      }

      http.Response response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      if (kDebugMode) {
        if (showResponse == true) {
          log("API Response Url........  $url");
          log("API Response........  ${response.body}");
          log("API Response Status Code........  ${response.statusCode}");
          log("API Response Reason Phrase........  ${response.reasonPhrase}");
        }
      }

      Helpers.hideLoader(loader);

      if (response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      }  else if (response.statusCode == 401 && response.body == "Unauthorized") {
        // Get.offAll(AccountTypeScreen());
        logOutUser();
      } else {
        // showToast(response.body);
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      // showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      throw Exception(e);
    }
  }

  Future<dynamic> deleteApi({
    BuildContext? context,
    required String url,
    // bool? showLoader = false,
    bool? showMap = false,
    Function(int status, String response)? withStatus,
    bool? showResponse = true,
    Map<String, dynamic>? mapData,
    Color? color,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};

      if (kDebugMode) {
        log("API Url.....  $url");
        log("API mapData.....  $mapData");
        if (true) {
          log("API headers.....  $headers");
        }
      }

      http.Response response = await http.delete(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      if (kDebugMode) {
        if (showResponse == true) {
          log("API Response Url........  $url");
          log("API Response........  ${response.body}");
          log("API Response Status Code........  ${response.statusCode}");
          log("API Response Reason Phrase........  ${response.reasonPhrase}");
        }
      }

      Helpers.hideLoader(loader);

      if (response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      }  else if (response.statusCode == 401 && response.body == "Unauthorized") {
        // Get.offAll(AccountTypeScreen());
        logOutUser();
      } else {
        // showToast(response.body);
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      // showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      throw Exception(e);
    }
  }

  Future<dynamic> getApi({
    BuildContext? context,
    required String url,
    bool? showMap = true,
    bool? showResponse = true,
    bool? returnResponse = false,
    bool? saveToLocal = false,
    dynamic mapData,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};

      // if (kDebugMode) {
      print("API Url.....  $url");
      print("API headers.....  $headers");
      print("Map Data.....  $mapData");
      // }

      // http.Response response = await http.get(Uri.parse(url), headers: headers);

      var request = http.Request('GET', Uri.parse(url));
      if (mapData != null) {
        request.body = jsonEncode(mapData);
      }
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String response1 = await response.stream.bytesToString();

      // if (kDebugMode) {
      if (showResponse == true) {
        log("API Url.....  $url");
        debugPrint("API Response........  $response1", wrapWidth: 1024);
        //print("API Response........  $response1");
        log("API Response Status Code........  ${response.statusCode}");
        log("API Response Reason Phrase........  ${response.reasonPhrase}");
        // print("API Response Reason Phrase........  ${response.reasonPhrase}");
      }
      // }

      Helpers.hideLoader(loader);
      if (returnResponse!) {
        return response;
      } else {
        if (response.statusCode == 200 ||
            response.statusCode == 400 ||
            response.statusCode == 201 ||
            response.statusCode == 404) {
          if (saveToLocal == true) {
            //SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            //  sharedPreferences.setString(url, response1);
          }
          return response1;
        }  else if (response.statusCode == 401 && response1.trim() == "Unauthorized") {
          // Get.offAll(AccountTypeScreen());
          logOutUser();
          // throw Exception("Unauthorized");
          return response1.toString();
        }else {
          // showToast(response.body);
          return response1;
        }
      }
    } on SocketException {
      Helpers.hideLoader(loader);
      //  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      // if(sharedPreferences.getString(url) != null){
      //return sharedPreferences.getString(url);
      //  } else {
      showSnackBar("No Internet Access", false);
      throw Exception("No Internet Access");
      //  }
    } catch (e) {
      Helpers.hideLoader(loader);
      // showToast(e.toString());
      throw Exception(e);
    }
  }

  Future<dynamic> multiPartApi({
    required mapData,
    required Map<String, File> images,
    BuildContext? context,
    Color? color,
    required String url,
    required Function(int bytes, int totalBytes) onProgress,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};
      images.removeWhere((key, value) => !value.existsSync());
      var request = CloseableMultipartRequest(
        'POST',
        Uri.parse(url),
        onProgress: (int bytes, int totalBytes) {
          if (images.isNotEmpty) {
            onProgress(bytes, totalBytes);
          }
        },
      );
      request.headers.addAll(headers);

      request.fields.addAll(mapData);
      for (var item in images.entries) {
        if (item.value.existsSync()) {
          request.files.add(
            await _multipartFile(item.key.toString(), item.value),
          );
        }
      }
      // if (kDebugMode) {
      log(url);
      log(request.headers.toString());
      log(request.fields.toString());
      log(images.toString());
      log(request.files.map((e) => e.filename).toList().toString());
      // }

      final response = await request.send();
      String value = await response.stream.bytesToString();
      log("Api Response.....      $value");
      log(response.statusCode.toString());
      Helpers.hideLoader(loader);
      if (response.statusCode == 200) {
        return value;
      }  else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        Helpers.hideLoader(loader);
        // Get.offAll(AccountTypeScreen());
        logOutUser();
        return value.toString();
      }else {
        Helpers.hideLoader(loader);
        throw Exception(value);
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      //showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      // showToast("Something went wrong.....${e.toString().substring(0, math.min(e.toString().length, 50))}");
      throw Exception(e);
    }
  }

  Future<dynamic> multiPartPostApi({
    required mapData,
    required Map<String, File> images,
    BuildContext? context,
    Color? color,
    required String url,
    required Function(int bytes, int totalBytes) onProgress,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};
      images.removeWhere((key, value) => !value.existsSync());
      var request = CloseableMultipartRequest(
        'PUT',
        Uri.parse(url),
        onProgress: (int bytes, int totalBytes) {
          if (images.isNotEmpty) {
            onProgress(bytes, totalBytes);
          }
        },
      );
      request.headers.addAll(headers);

      request.fields.addAll(mapData);
      for (var item in images.entries) {
        if (item.value.existsSync()) {
          request.files.add(
            await _multipartFile(item.key.toString(), item.value),
          );
        }
      }
      // if (kDebugMode) {
      log(url);
      log(request.headers.toString());
      log(request.fields.toString());
      log(images.toString());
      log(request.files.map((e) => e.filename).toList().toString());
      // }

      final response = await request.send();
      String value = await response.stream.bytesToString();
      log("Api Response.....      $value");
      log(response.statusCode.toString());
      Helpers.hideLoader(loader);
      if (response.statusCode == 200) {
        return value;
      }  else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        // Get.offAll(AccountTypeScreen());
        Helpers.hideLoader(loader);
        // Get.offAll(AccountTypeScreen());
        logOutUser();
        // throw Exception("Unauthorized");
        return value.toString();
      } else {
        Helpers.hideLoader(loader);
        throw Exception(value);
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      //showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      // showToast("Something went wrong.....${e.toString().substring(0, math.min(e.toString().length, 50))}");
      throw Exception(e);
    }
  }

  Future<dynamic> multiPartPatchApi({
    required mapData,
    required Map<String, File> images,
    BuildContext? context,
    Color? color,
    required String url,
    required Function(int bytes, int totalBytes) onProgress,
  }) async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Overlay.of(context).insert(loader);
      });
      // Overlay.of(context).insert(loader);
    }

    try {
      final Map<String, String> headers =
      await ManageTokens.getHttpHeadersWithToken();
      mapData ??= {};
      images.removeWhere((key, value) => !value.existsSync());
      var request = CloseableMultipartRequest(
        'PATCH',
        Uri.parse(url),
        onProgress: (int bytes, int totalBytes) {
          if (images.isNotEmpty) {
            onProgress(bytes, totalBytes);
          }
        },
      );
      request.headers.addAll(headers);

      request.fields.addAll(mapData);
      for (var item in images.entries) {
        if (item.value.existsSync()) {
          request.files.add(
            await _multipartFile(item.key.toString(), item.value),
          );
        }
      }
      // if (kDebugMode) {
      log(url);
      log(request.headers.toString());
      log(request.fields.toString());
      log(images.toString());
      log(request.files.map((e) => e.filename).toList().toString());
      // }

      final response = await request.send();
      String value = await response.stream.bytesToString();
      log("Api Response.....      $value");
      log(response.statusCode.toString());
      Helpers.hideLoader(loader);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return value;
      } else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        logOutUser();
        // Get.offAll(AccountTypeScreen());
        // throw Exception(value);
      } else {
        Helpers.hideLoader(loader);
        throw Exception(value);
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      //showToast("No Internet Access");
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      // showToast("Something went wrong.....${e.toString().substring(0, math.min(e.toString().length, 50))}");
      throw Exception(e);
    }
  }

  Future<http.MultipartFile> _multipartFile(
      String? fieldName,
      File file1,
      ) async {
    return http.MultipartFile(
      fieldName ?? 'file',
      http.ByteStream(Stream.castFrom(file1.openRead())),
      await file1.length(),
      filename: file1.path.split('/').last,
    );
  }

  Future<void> logOutUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // Get.offAllNamed(LoginScreen.loginScreen);
  }
}

Future<void> signOut() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  // Get.offAllNamed(LoginScreen.loginScreen);
}

class CloseableMultipartRequest extends http.MultipartRequest {
  http.Client client = http.Client();

  CloseableMultipartRequest(
      super.method,
      super.uri, {
        required this.onProgress,
      });

  void close() => client.close();

  @override
  Future<http.StreamedResponse> send() async {
    try {
      var response = await client.send(this);
      var stream = onDone(response.stream, client.close);
      return http.StreamedResponse(
        http.ByteStream(stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      client.close();
      rethrow;
    }
  }

  final void Function(int bytes, int totalBytes) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    // if (onProgress == null) return byteStream;

    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        if (total >= bytes) {
          sink.add(data);
        }
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }

  Stream<T> onDone<T>(Stream<T> stream, void Function() onDone) =>
      stream.transform(
        StreamTransformer.fromHandlers(
          handleDone: (sink) {
            sink.close();
            onDone();
          },
        ),
      );
}
