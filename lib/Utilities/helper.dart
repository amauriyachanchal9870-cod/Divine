import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'app_theme.dart';

class Helpers {
  late BuildContext context;
  late DateTime currentBackPressTime;
  static const kGoogleApiKey = "AIzaSyDwrRWL28FsfKlsnf58vTu-YQ3DKJpgHqM";

  Helpers.of(BuildContext context) {
    context = context;
  }
  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      return Positioned.fill(
        child: Material(
          color: Colors.white.withValues(alpha: 0.8),
          child: Center(
            child: LoadingAnimationWidget.threeRotatingDots(
              color: AppTheme.primaryDeepBlue,
              size: 50,
            ),
          ),
        ),
      );
    });
    return loader;
  }

  RxInt refreshUi = 0.obs;
  updateUI() {
    refreshUi.value = DateTime.now().microsecondsSinceEpoch;
  }

  static hideLoader(OverlayEntry loader) {
    try {
      loader.remove();
    } catch (e) {}
  }
}

String cleanHtml(String rawHtml) {
  final document = html_parser.parse(rawHtml);
  final unescape = HtmlUnescape();
  String parsedText = unescape.convert(document.body?.text ?? "");
  parsedText = parsedText.replaceAll(RegExp(r'\s+'), ' ').trim();
  return parsedText;
}

void requestFocus(FocusNode node, BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).requestFocus(node);
  });
}

Future<TimeOfDay?> selectTime(BuildContext context) async {
  return await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
}

String _formatCompact(num val) {
  String str = val.toDouble().toStringAsFixed(2);
  if (str.contains('.')) {
    str = str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return str;
}

String formatPrice(num price) {
  if (price >= 1000000000) {
    num val = price / 1000000000;
    return '${_formatCompact(val)}B';
  } else if (price >= 1000000) {
    num val = price / 1000000;
    return '${_formatCompact(val)}M';
  } else if (price >= 1000) {
    num val = price / 1000;
    return '${_formatCompact(val)}K';
  } else {
    return price % 1 == 0 ? price.toInt().toString() : _formatCompact(price);
  }
}

bool isBefore(TimeOfDay t1, TimeOfDay t2) {
  final t1Minutes = t1.hour * 60 + t1.minute;
  final t2Minutes = t2.hour * 60 + t2.minute;
  return t1Minutes < t2Minutes;
}

bool isSameDate(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

bool isAfterOrEqual(TimeOfDay t1, TimeOfDay t2) {
  final int t1Minutes = t1.hour * 60 + t1.minute;
  final int t2Minutes = t2.hour * 60 + t2.minute;
  return t1Minutes >= t2Minutes;
}

String formatTime(TimeOfDay? time) {
  if (time == null) return '--:--';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String maskName(String name) {
  if (name.trim().isEmpty) return name;
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    final single = parts.first;
    if (single.length <= 2) return single;
    return '${single[0]}${'*' * (single.length - 2)}${single[single.length - 1]}';
  }
  final first = parts.first;
  final last = parts.last;
  String maskedFirst = first.length <= 2
      ? first
      : '${first[0]}${'*' * (first.length - 2)}${first[first.length - 1]}';
  String maskedLast = last.length <= 2
      ? last
      : '${last[0]}${'*' * (last.length - 2)}${last[last.length - 1]}';
  return '$maskedFirst $maskedLast';
}

String formatErrorMessage(dynamic message) {
  if (message == null) {
    return "Please check your internet connection";
  }

  String text = message.toString().trim();
  if (text.isEmpty) {
    return "Something went wrong. Please try again.";
  }

  final lower = text.toLowerCase();

  if (lower.contains("socketexception") ||
      lower.contains("clientexception") ||
      lower.contains("connection timed out") ||
      lower.contains("timed out") ||
      lower.contains("connection refused") ||
      lower.contains("connection reset") ||
      lower.contains("connection closed") ||
      lower.contains("failed host lookup") ||
      lower.contains("network is unreachable") ||
      lower.contains("software caused connection abort") ||
      lower.contains("handshakeexception") ||
      lower.contains("timeoutexception") ||
      lower.contains("httpexception") ||
      lower.contains("no internet") ||
      lower.contains("network error") ||
      lower.contains("networkerror") ||
      lower.contains("errno = 110") ||
      lower.contains("errno = 111") ||
      lower.contains("errno = 101") ||
      lower.contains("errno = 104") ||
      lower.contains("errno = 113") ||
      lower.contains("errno = 7") ||
      lower.contains("os error")) {
    return "Please check your internet connection";
  }

  if (text.startsWith("Error: Exception: ")) {
    text = text.substring("Error: Exception: ".length);
  } else if (text.startsWith("Exception: ")) {
    text = text.substring("Exception: ".length);
  } else if (text.startsWith("Error: ")) {
    text = text.substring("Error: ".length);
  }

  return text.trim();
}

showSnackBar(String? title, bool? check) {
  final displayTitle = check == true ? (title ?? "") : formatErrorMessage(title);
  Get.closeAllSnackbars();
  Get.snackbar(
    "",
    "",
    titleText: Container(
      decoration: BoxDecoration(
        color: AppTheme.formCounterColor,
        border: Border(
          bottom: BorderSide(width: 1, color: AppTheme.borderColor),
          top: BorderSide(width: 1, color: AppTheme.borderColor),
          right: BorderSide(width: 1, color: AppTheme.borderColor),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    messageText: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.formCounterColor,
        border: Border(
          left: BorderSide(width: 5.0, color: check == true ? AppTheme.themeColor : const Color(0xffFF3931)),
          bottom: BorderSide(width: 0.00001, color: check == true ? AppTheme.themeColor : const Color(0xffFF3931)),
          top: BorderSide(width: 0.00001, color: check == true ? AppTheme.themeColor : const Color(0xffFF3931)),
          right: BorderSide(width: 0.00001, color: check == true ? AppTheme.themeColor : const Color(0xffFF3931)),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: check == true ? AppTheme.themeColor : const Color(0xffFF3931),
            radius: 10,
            child: Icon(
              check == true ? Icons.check : Icons.close,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              displayTitle,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
              maxLines: 4,
            ),
          ),
        ],
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    overlayColor: Colors.transparent,
    barBlur: 0,
  );
}