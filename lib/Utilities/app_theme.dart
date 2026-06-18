import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class AppTheme extends GetxController{
  RxBool isDarkTheme = true.obs;
  RxInt refreshInt = 0.obs;
  static Color primaryColor = const Color(0xFFFFFFFF);
  static Color secondaryColor = const Color(0xFF0A0D12);
  static Color backgroundWhiteColor = const Color(0xFFF5F3F5);
  static Color badgeborder = const Color(0xFFD9D6FE);
  static Color badgebackgroung = const Color(0xFFF4F3FF);
  static Color whiteColor = const Color(0xFFFFFFFF);
  static Color txtColor = const Color(0xFF000000);
  static Color buttonColor = const Color(0xFF74A46D);
  static Color dotColor = const Color(0xFF6ADB6F);
  static Color buttonColorGray = const Color(0xFFEBF3FF);
  static Color selectcontainer = const Color(0xFFEBF3FF);
  static Color hintTextColor = const Color(0xFF717680);

  static Color dividerColor = const Color(0xFFA4A7AE);

  static Color buttonColorDark = const Color(0xFF1f222A);
  static Color formCounterColor = const Color(0xFF111111);
  static Color formBorderColor = const Color(0xFF1F222A);
  static Color borderColor = const Color(0xFFD5D7DA);
  static Color subborderColor = const Color(0xffF5F5F5);
  static Color subTextColor = const Color(0xFF616161);
  static Color bottomTextColor = const Color(0xFF757575);
  static Color subHadingColor = const Color(0xFF616161);
  static Color themeColor = const Color(0xFF6ADB6F);
  static Color buttonTxtColor = const Color(0xFFFFFFFF);
  static Color buttonTxtColor1 = const Color(0xFFFFFFFF);
  static Color yellowColor = const Color(0xFFFBC900);
  static Color orangeColor = const Color(0xFFFF5626);
  static Color barrierColor = const Color(0xff09101D).withValues(alpha: .8);
  static Color redColor = const Color(0xFFF75555);
  static Color blueColor = const Color(0xFF1A96F0);
  static Color indigoColor = const Color(0xFF3F51B2);
  static Color yellowColor1 = const Color(0xFFFAC515);
  static Color paginationDotClr = const Color(0xFFCACACA);
  static Color redTextColor = const Color(0xFFEF4444);
  static Color linkTextColor = const Color(0xFF1877F2);
  static Color shineThemeColor = const Color(0xFF12D18E);
  static Color greenColor = const Color(0xFF079455);
  static Color limitedColor = const Color(0xFFFBC900);
  static Color textFieldColor = Colors.grey.shade100;
  static Color primaryBlue = const Color(0xFF1E3A8A);
  static Color socialBorderColor = const Color(0xFFD1D5DB);
  static Color fieldBorderColor = const Color(0xFFE5E7EB);
  static Color genderSelectColor = const Color(0xFFEBF3FF);
  static Color googleColor = const Color(0xFFDB4437);
  static Color fbColor = const Color(0xFF4267B2);
  static Color appleColor = const Color(0xFF000000);
  
  static Color borderGreyLighter = const Color(0xFFF1F1F1);
  static Color greyBg50 = const Color(0xFFF9FAFB);
  static Color greyBorderLight = const Color(0xFFEFEFEF);
  static Color greyBorderF0 = const Color(0xFFF0F0F0);
  static Color greyDividerE0 = const Color(0xFFE0E0E0);
  static Color greyBg100 = const Color(0xFFF3F4F6);
  static Color greyBorderCc = const Color(0xFFCCCCCC);
  static Color blueLightBg = const Color(0xFFEBF3FF);
  static Color ratingGreenBg = const Color(0xFF00BFA5);
  static Color categoryGreyBg = const Color(0xFFF3F6F8);
  static Color verifiedBlueBg = const Color(0xFFE3F2FD);
  static Color amberStars = const Color(0xFFFFC107);
  static Color greyBg300 = const Color(0xFFE0E0E0);
  
  static Color screenBackground = const Color(0xFFF2F2F2);
  static Color primaryDeepBlue = const Color(0xFF022658); // Updated to match design deep blue
  static Color lightCyanBackground = const Color(0xFFE8F5E9); // Light background for splash
  
  static Color donateGradientStart = const Color(0xFFA5D6A7);
  static Color donateGradientEnd = const Color(0xFF4CAF50);
  static Color raiseGradientStart = const Color(0xFF90CAF9);
  static Color raiseGradientEnd = const Color(0xFF1976D2);
  static Color progressGreen = const Color(0xFF4CAF50);
  static Color searchBarBg = const Color(0xFFF9FAFB);
  static Color textGrey500 = const Color(0xFF9E9E9E);
  static Color textGrey400 = const Color(0xFFBDBDBD);
  static Color textGrey200 = const Color(0xFFEEEEEE);
  static Color blackColor = const Color(0xFF000000);
  static Color bannerBgColor = const Color(0xFFEBE8FC);
  static Color bannerButtonGreen = const Color(0xFF0BA763);

  // Donate Flow Colors
  static Color successScreenBgTop = const Color(0xFF022658);
  static Color successScreenBgBottom = const Color(0xFF033A7A);
  static Color mastercardOrange = const Color(0xFFFF5F00);
  static Color visaBlue = const Color(0xFF1A1F71);
  static Color taxNoticeBg = const Color(0xFFF0F4FF);
  static Color addItemsBg = const Color(0xFFEBF3FF);
  static Color backButtonBg = const Color(0xFFEAEAEA);



  // static Color shineThemeColor = const Color(0xFF4CA30D);
  // static Color greenColor = const Color(0xFF01AE66);

  static Color field = const Color(0xFFF9F9F9);
  static Color borderyellow = const Color(0xFFFEDF89);
  static Color containeryellow = const Color(0xFFFFFAEB);
  static Color containertxt = const Color(0xFFB54708);
  static Color linegray = const Color(0xFFD5D7DA);

  static Color containerColor = const Color(0xFF2D2C3E);




  manageColors(){

    primaryColor = isDarkTheme.value ? const Color(0xFF000000):const Color(0xFFFFFFFF);
    txtColor = isDarkTheme.value ? const Color(0xFFFFFFFF):const Color(0xFF212121);
    subTextColor = isDarkTheme.value ? const Color(0xFFEEEEEE):const Color(0xFF616161);
    buttonColorGray = isDarkTheme.value ? const Color(0xFF333333):const Color(0xFFEBF9F3);
    buttonTxtColor = isDarkTheme.value ? const Color(0xFFFFFFFF):const Color(0xFF01AE66);
    buttonColorDark = isDarkTheme.value ? const Color(0xFF1f222A):const Color(0xFFFFFFFF);
    buttonTxtColor1 = isDarkTheme.value ? const Color(0xFFFFFFFF):const Color(0xFF212121);
    borderColor = isDarkTheme.value ? const Color(0xFF35383F):const Color(0xFFEEEEEE);
    formCounterColor = isDarkTheme.value ? const Color(0xFF111111):const Color(0xFFFAFAFA);
    formBorderColor = isDarkTheme.value ? const Color(0xFF1F222A):const Color(0xFFFAFAFA);
    refreshInt.value=DateTime.now().microsecondsSinceEpoch;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // manageColors();

  }
}




