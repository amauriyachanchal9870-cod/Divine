
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html_parser;


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
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: AppTheme.primaryColor.withValues(alpha: 0.02),
          child:  Center(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryDeepBlue,))
            // CircularProgressIndicator(
            //   color: AppTheme.white,
            //
            // ),
          ),
        ),
      );
    });
    return loader;
  }

  RxInt refreshUi = 0.obs;
  updateUI(){
    refreshUi.value = DateTime.now().microsecondsSinceEpoch;
  }


  static hideLoader(OverlayEntry loader) {
    Timer(const Duration(milliseconds: 250), () {
      try {
        loader.remove();
      } catch (e) {}
    });
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

String formatPrice(num price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}M';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
  } else {
    return price.toString();
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
  if (name.isEmpty) {
    return '';
  }

  int minLength=19;
  LengthLimitingTextInputFormatter lengthFormatter = LengthLimitingTextInputFormatter(minLength);

  // MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(mask: '+1 (###) ### - ####', filter: {"#": RegExp(r'[0-9]')});


  final RegExp regex = RegExp(r'^(Mr\.|Mrs\.|Dr\.|Ms\.|Miss)\s*');
  String cleanName = name.replaceAll(regex, '').trim();

  String maskedName = cleanName[0];

  for (int i = 1; i < cleanName.length; i++) {
    if (cleanName[i] == ' ') {
      maskedName += ' ';
    } else {
      maskedName += '*';
    }
  }

  return maskedName;
}

String getInitials(String fullName) {
  final RegExp regex = RegExp(r'^(Mr\.|Mrs\.|Dr\.|Ms\.|Miss)\s*');
  String cleanName = fullName.replaceAll(regex, '').trim();

  List<String> nameParts = cleanName.split(" ");

  String firstName = nameParts.isNotEmpty ? nameParts[0] : "";
  String lastName = nameParts.length > 1 ? nameParts[nameParts.length - 1] : "";

  String firstLetter = firstName.isNotEmpty ? firstName[0].toUpperCase() : "";
  String lastLetter = lastName.isNotEmpty ? lastName[0].toUpperCase() : "";

  return firstLetter + lastLetter;
}

String cleanPhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith('+1')) {
    phoneNumber = phoneNumber.substring(2); // Remove the first two characters
  }
  String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  return cleanedNumber; // Add the '+' back to the cleaned number
}
String formatPhoneNumber(String phoneNumber) {
  if (kDebugMode) {
    // print("phone length------ ${phoneNumber.length}");
  }
  if (phoneNumber.length == 11) {
    if (phoneNumber.startsWith('1')) {
      phoneNumber = phoneNumber.substring(1);
    } // Return the original string if it doesn't have 10 digits
  }

  String convertDateToText(String? dateStr) {
    if (dateStr == null) {
      return "";
    }
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return "Today";
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Yesterday, ${DateFormat('MMM dd, yyyy').format(date)}';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return "Invalid Date";
    }
  }



  if (phoneNumber.length != 10) {
    return phoneNumber; // Return the original string if it doesn't have 10 digits
  }

  final String countryCode = phoneNumber.substring(0, 3);
  final String firstPart = phoneNumber.substring(3, 6);
  final String secondPart = phoneNumber.substring(6, 10);

  return '+1 ($countryCode) $firstPart - $secondPart';
}
Color convertHexToColor(String hexColor) {
  // Remove # if present and ensure uppercase
  hexColor = hexColor.toUpperCase().replaceAll("#", "");

  // Check if the hex string contains only valid hex characters (0-9, A-F)
  final validHexRegex = RegExp(r'^[0-9A-F]+$');

  if (!validHexRegex.hasMatch(hexColor)) {
    return Colors.grey; // Default color for invalid input
  }

  if (hexColor.length == 8) {
    return Color(int.parse(hexColor, radix: 16));
  } else if (hexColor.length == 6) {
    return Color(int.parse("FF$hexColor", radix: 16));
  } else {
    return AppTheme.primaryColor; // Default color for invalid length
  }
}

Future<DateTime?> selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(Duration(days: 1)),
    firstDate: DateTime.now().add(Duration(days: 1)),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    return pickedDate;  // Update state with the selected date
  }
  else{
    return null;
  }
}


showSnackBar(String? title, bool? check) {
  Get.closeAllSnackbars();
  //Get.closeCurrentSnackbar();
  // scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  Get.snackbar(
    "","",
    titleText: Container(
      decoration: BoxDecoration(
          color: AppTheme.formCounterColor,
          border:  Border(
              bottom:  BorderSide(width: 1, color:AppTheme.borderColor),
              top: BorderSide(width: 1, color: AppTheme.borderColor),
              right: BorderSide(width: 1, color: AppTheme.borderColor)),
          borderRadius: BorderRadius.circular(5)),

      child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 15),
          decoration: BoxDecoration(
              color: AppTheme.formCounterColor,
              border:  Border(
                  left: BorderSide(width: 5.0, color: check == true ? AppTheme.themeColor: const Color(0xffFF3931)),
                  bottom:  BorderSide(width: 0.00001, color:check == true? AppTheme.themeColor: const Color(0xffFF3931)),
                  top: BorderSide(width: 0.00001, color: check == true? AppTheme.themeColor: const Color(0xffFF3931)),
                  right: BorderSide(width: 0.00001, color: check == true? AppTheme.themeColor: const Color(0xffFF3931))),
              borderRadius: BorderRadius.circular(5)),
          child:  Row(
            children: [
              CircleAvatar(
                backgroundColor: check==true ?  AppTheme.themeColor : const Color(0xffFF3931),
                radius: 10,
                child: Icon( check==true ? Icons.check :Icons.close, color: Colors.white, size: 15,),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,color: AppTheme.primaryColor),
                  maxLines: 4,),
              ),
            ],
          )),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    overlayColor:Colors.transparent,
    barBlur: 0,


  );

  //log("secces::show ");





//   scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
//   log("leee${title.toString().length}");
//   int no= title.toString().length>100 ? 250:230;
//   final snackBar = SnackBar(
//     margin: EdgeInsets.only(
//        bottom: scaffoldMessengerKey.currentContext!.height - no),
//
//     content: Container(
//       decoration: BoxDecoration(
//           color: AppTheme.popupColor,
//           border:  Border(
//               bottom:  BorderSide(width: 1, color:AppTheme.borderColor),
//               top: BorderSide(width: 1, color: AppTheme.borderColor),
//               right: BorderSide(width: 1, color: AppTheme.borderColor)),
//           borderRadius: BorderRadius.circular(5)),
//
//       child: Container(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 8, vertical: 15),
//           decoration: BoxDecoration(
//               color: AppTheme.popupColor,
//               border:  Border(
//                   left: BorderSide(width: 5.0, color: check ==true? const Color(0xff2DB963): const Color(0xffFF3931)),
//                   bottom:  BorderSide(width: 0.00001, color:check ==true? const Color(0xff2DB963): const Color(0xffFF3931)),
//                   top: BorderSide(width: 0.00001, color: check ==true? const Color(0xff2DB963): const Color(0xffFF3931)),
//                   right: BorderSide(width: 0.00001, color: check ==true? const Color(0xff2DB963): const Color(0xffFF3931))),
//               borderRadius: BorderRadius.circular(5)),
//           child:  Row(
//             children: [
//                CircleAvatar(
//                 backgroundColor:check==true?  const Color(0xff2DB963):const Color(0xffFF3931),
//                 radius: 10,
//                 child: Icon( check==true?Icons.check:Icons.close, color: Colors.white, size: 15,),
//               ),
//               const SizedBox(width: 8),
//               Flexible(
//                 child: Text(title.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,color: AppTheme.txtNew),
//                 maxLines: 5,),
//               ),
//             ],
//           )),
//     ),
//     behavior: SnackBarBehavior.floating,
//     elevation: 0,
//     backgroundColor: Colors.transparent,
//    dismissDirection: DismissDirection.startToEnd,
//    // duration: Duration(seconds: 1),
//
//   );
//
//   scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
// }
// hideCurrentSnackBar(){
//  // showSnackBar = false;
//   scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
}