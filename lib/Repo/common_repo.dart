import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Routes/my_routes.dart';
import '../Token Manager/token_manager.dart';
import '../Utilities/helper.dart';

class ApiLogger {
  static const bool _verboseLogging = kDebugMode;

  static Map<String, dynamic> sanitizeMap(Map<String, dynamic>? data) {
    if (data == null) return {};
    final sanitized = <String, dynamic>{};
    const sensitiveKeys = {
      'password',
      'oldpassword',
      'newpassword',
      'pin',
      'otp',
      'token',
      'accesstoken',
      'refreshtoken',
      'authorization',
      'idtoken',
      'authorizationcode',
      'secret',
    };

    data.forEach((key, value) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        sanitized[key] = '[PROTECTED]';
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = sanitizeMap(value);
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static Map<String, String> sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    final sanitized = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization' || key.toLowerCase().contains('token')) {
        sanitized[key] = value.startsWith('Bearer ') ? 'Bearer [PROTECTED]' : '[PROTECTED]';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    if (!_verboseLogging) return;
    debugPrint("🌐 [API REQUEST] $method $url");
    if (body != null && body.isNotEmpty) {
      debugPrint("   Payload: ${jsonEncode(sanitizeMap(body))}", wrapWidth: 1024);
    }
  }

  static void logDeduplicated({
    required String method,
    required String url,
  }) {
    if (!_verboseLogging) return;
    debugPrint("⚡ [API DEDUPLICATED] $method $url (Reusing in-flight request)");
  }

  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required String responseBody,
  }) {
    if (!_verboseLogging) return;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final prefix = isSuccess ? "✅ [API SUCCESS]" : "⚠️ [API STATUS $statusCode]";
    debugPrint("$prefix $method $url");
    debugPrint("   Status: $statusCode | Body: $responseBody", wrapWidth: 1024);
  }

  static void logError({
    required String method,
    required String url,
    required dynamic error,
  }) {
    if (!_verboseLogging) return;
    debugPrint("❌ [API FAILED] $method $url | Error: $error");
  }
}

class Repositories {
  // In-flight GET request deduplication cache to prevent identical parallel requests
  static final Map<String, Future<dynamic>> _inFlightGetRequests = {};

  // Flag to debounce simultaneous 404 redirect requests and prevent redirect loops
  static bool _isHandling404 = false;

  /// Central check to determine if an HTTP response represents a 404 Not Found error
  /// or an invalid/deleted user state from the server.
  static bool _is404(int statusCode, String? body) {
    if (statusCode == 404) return true;
    if (body != null && body.trim().isNotEmpty) {
      final trimmed = body.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            if (decoded['status'] == 404 ||
                decoded['statusCode'] == 404 ||
                decoded['code'] == 404) {
              return true;
            }
            final msg = decoded['message']?.toString().toLowerCase().trim();
            if (decoded['status'] == false &&
                (msg == 'user not found' ||
                 msg == 'user does not exist' ||
                 msg == 'account not found' ||
                 msg == 'account deleted' ||
                 msg == 'user deleted')) {
              return true;
            }
          }
        } catch (_) {}
      }
    }
    return false;
  }

  /// Global exception/error handler for HTTP 404 responses.
  /// When a user account is deleted by an admin or an invalid resource triggers 404,
  /// this clears authentication session state and redirects the user to the Login screen.
  static Future<void> handleNotFound404() async {
    if (_isHandling404) return;
    _isHandling404 = true;

    try {
      debugPrint("🚫 [GLOBAL ERROR HANDLER] HTTP 404 detected. Invalidating session and redirecting to Login.");

      // Clear all auth tokens, cookies, cached preferences, and in-memory controllers
      await ManageTokens.clearAllAuthSession();

      if (Get.currentRoute != MyRouters.loginScreen) {
        showSnackBar("Account not found. Please log in again.", false);
        if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.currentRoute != MyRouters.loginScreen) {
              Get.offAllNamed(MyRouters.loginScreen);
            }
          });
        } else {
          Get.offAllNamed(MyRouters.loginScreen);
        }
      }
    } catch (e) {
      debugPrint("Error in handleNotFound404: $e");
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isHandling404 = false;
      });
    }
  }

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

      ApiLogger.logRequest(
        method: 'POST',
        url: url,
        body: mapData,
        headers: headers,
      );

      http.Response response = await http.post(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      Helpers.hideLoader(loader);

      ApiLogger.logResponse(
        method: 'POST',
        url: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (_is404(response.statusCode, response.body)) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      } else if (response.statusCode == 401 && response.body == "Unauthorized") {
        await logOutUser();
        return response.body;
      } else {
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'POST', url: url, error: 'No internet access ($e)');
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'POST', url: url, error: e);
      throw Exception(e);
    }
  }

  Future<dynamic> putApi({
    BuildContext? context,
    required String url,
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

      ApiLogger.logRequest(
        method: 'PUT',
        url: url,
        body: mapData,
        headers: headers,
      );

      http.Response response = await http.put(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      Helpers.hideLoader(loader);

      ApiLogger.logResponse(
        method: 'PUT',
        url: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (_is404(response.statusCode, response.body)) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      } else if (response.statusCode == 401 && response.body == "Unauthorized") {
        await logOutUser();
        return response.body;
      } else {
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'PUT', url: url, error: 'No internet access ($e)');
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'PUT', url: url, error: e);
      throw Exception(e);
    }
  }

  Future<dynamic> patchApi({
    BuildContext? context,
    required String url,
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

      ApiLogger.logRequest(
        method: 'PATCH',
        url: url,
        body: mapData,
        headers: headers,
      );

      http.Response response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      Helpers.hideLoader(loader);

      ApiLogger.logResponse(
        method: 'PATCH',
        url: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (_is404(response.statusCode, response.body)) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      } else if (response.statusCode == 401 && response.body == "Unauthorized") {
        await logOutUser();
        return response.body;
      } else {
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'PATCH', url: url, error: 'No internet access ($e)');
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'PATCH', url: url, error: e);
      throw Exception(e);
    }
  }

  Future<dynamic> deleteApi({
    BuildContext? context,
    required String url,
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

      ApiLogger.logRequest(
        method: 'DELETE',
        url: url,
        body: mapData,
        headers: headers,
      );

      http.Response response = await http.delete(
        Uri.parse(url),
        body: jsonEncode(mapData),
        headers: headers,
      );

      Helpers.hideLoader(loader);

      ApiLogger.logResponse(
        method: 'DELETE',
        url: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (_is404(response.statusCode, response.body)) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200 ||
          response.statusCode == 400 ||
          response.statusCode == 201) {
        if (withStatus != null) {
          withStatus(response.statusCode, response.body);
        }
        return response.body;
      } else if (response.statusCode == 401 && response.body == "Unauthorized") {
        await logOutUser();
        return response.body;
      } else {
        return response.body;
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'DELETE', url: url, error: 'No internet access ($e)');
      throw Exception(e);
    } catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'DELETE', url: url, error: e);
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
    // In-flight deduplication: If an identical GET request is already pending, reuse its Future
    final String dedupeKey = "GET:$url:${mapData != null ? jsonEncode(mapData) : ''}";
    if (_inFlightGetRequests.containsKey(dedupeKey)) {
      ApiLogger.logDeduplicated(method: 'GET', url: url);
      return await _inFlightGetRequests[dedupeKey]!;
    }

    final future = _executeGetApi(
      context: context,
      url: url,
      showMap: showMap,
      showResponse: showResponse,
      returnResponse: returnResponse,
      saveToLocal: saveToLocal,
      mapData: mapData,
    );

    _inFlightGetRequests[dedupeKey] = future;
    try {
      return await future;
    } finally {
      _inFlightGetRequests.remove(dedupeKey);
    }
  }

  Future<dynamic> _executeGetApi({
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

      ApiLogger.logRequest(
        method: 'GET',
        url: url,
        body: mapData is Map<String, dynamic> ? mapData : null,
        headers: headers,
      );

      var request = http.Request('GET', Uri.parse(url));
      if (mapData != null && mapData is Map && mapData.isNotEmpty) {
        request.body = jsonEncode(mapData);
      }
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String response1 = await response.stream.bytesToString();

      Helpers.hideLoader(loader);

      ApiLogger.logResponse(
        method: 'GET',
        url: url,
        statusCode: response.statusCode,
        responseBody: response1,
      );

      if (returnResponse!) {
        return response;
      } else {
        if (_is404(response.statusCode, response1)) {
          await handleNotFound404();
          return null;
        } else if (response.statusCode == 200 ||
            response.statusCode == 400 ||
            response.statusCode == 201) {
          return response1;
        } else if (response.statusCode == 401 && response1.trim() == "Unauthorized") {
          await logOutUser();
          return response1.toString();
        } else {
          return response1;
        }
      }
    } on SocketException catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'GET', url: url, error: 'No internet access ($e)');
      showSnackBar("Please check your internet connection", false);
      throw Exception("Please check your internet connection");
    } catch (e) {
      Helpers.hideLoader(loader);
      ApiLogger.logError(method: 'GET', url: url, error: e);
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
      headers.removeWhere((key, value) => key.toLowerCase() == 'content-type');
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
      if (_is404(response.statusCode, value)) {
        Helpers.hideLoader(loader);
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200) {
        return value;
      } else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        Helpers.hideLoader(loader);
        await logOutUser();
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
      headers.removeWhere((key, value) => key.toLowerCase() == 'content-type');
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
      if (_is404(response.statusCode, value)) {
        Helpers.hideLoader(loader);
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200) {
        return value;
      } else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        Helpers.hideLoader(loader);
        await logOutUser();
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
      headers.removeWhere((key, value) => key.toLowerCase() == 'content-type');
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
      if (_is404(response.statusCode, value)) {
        Helpers.hideLoader(loader);
        await handleNotFound404();
        return null;
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        return value;
      } else if (response.statusCode == 401 && value.trim() == "Unauthorized") {
        await logOutUser();
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
    await ManageTokens.clearAllAuthSession();
    if (Get.currentRoute != MyRouters.loginScreen) {
      if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != MyRouters.loginScreen) {
            Get.offAllNamed(MyRouters.loginScreen);
          }
        });
      } else {
        Get.offAllNamed(MyRouters.loginScreen);
      }
    }
  }
}

Future<void> signOut() async {
  await ManageTokens.clearAllAuthSession();
  if (Get.currentRoute != MyRouters.loginScreen) {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != MyRouters.loginScreen) {
          Get.offAllNamed(MyRouters.loginScreen);
        }
      });
    } else {
      Get.offAllNamed(MyRouters.loginScreen);
    }
  }
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
