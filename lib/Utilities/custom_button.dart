import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';


class CustomButton extends StatefulWidget {
  final double width;
  final double height;
  final String? title;
  final String? picture;
  final double? pictureHeight;
  final bool? showLoader;
  final bool? isBottomSpace;
  final Color? titleColor;
  final Color? pictureColor;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final GestureTapCallback onTap;
  final bool? showCenter;

  const CustomButton({
    super.key,
    required this.height,
    required this.width,
    this.title,
    this.isBottomSpace,
    required this.onTap,
    this.showLoader,
    this.borderRadius,
    this.color,
    this.border,
    this.titleColor,
    this.pictureColor,
    this.picture,
    this.pictureHeight,
    this.showCenter,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Padding(
      padding:  EdgeInsets.only(bottom: widget.isBottomSpace != null? 0: Platform.isAndroid ? 10 : 15),
      child: ElevatedButton(
        onPressed: widget.showLoader == true ? null : widget.onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: widget.titleColor ?? AppTheme.whiteColor,
          backgroundColor: widget.color ?? AppTheme.buttonColor, // Button text color
          disabledBackgroundColor: widget.color ?? AppTheme.buttonColor,
          disabledForegroundColor: widget.titleColor ?? AppTheme.whiteColor,
          minimumSize: Size(widget.width, widget.isBottomSpace != null ? widget.height: size.height*.06), // Button size
          shape: RoundedRectangleBorder(
            borderRadius:widget.borderRadius ?? BorderRadius.circular(14),
            side: widget.border != null ? BorderSide(color: widget.border!.top.color) : BorderSide.none, // Button border
          ),
        ),
        child: widget.showLoader == true
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment:  widget.title != null  ?  widget.showCenter == null? MainAxisAlignment.spaceBetween:MainAxisAlignment.center:MainAxisAlignment.center,
                children: [
                  widget.picture != null
                      ? SvgPicture.asset(
                          widget.picture!,
                          height: widget.pictureHeight!,
                          colorFilter: widget.pictureColor != null
                              ? ColorFilter.mode(widget.pictureColor!, BlendMode.srcIn)
                              : null,
                        )
                      : const SizedBox.shrink(),
                  if(widget.showCenter != null)
                    SizedBox(width: size.width*.04),
                  widget.title != null?
                  Text(
                    widget.title!,
                    // overflow: TextOverflow.fade,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ):const SizedBox.shrink(),
                  const SizedBox.shrink()
                ],
              ),
      ),
    );
  }
}
