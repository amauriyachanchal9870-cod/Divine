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
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: widget.titleColor ?? AppTheme.whiteColor,
          backgroundColor: widget.color ?? AppTheme.buttonColor, // Button text color
          minimumSize: Size(widget.width, widget.isBottomSpace != null ? widget.height: size.height*.06), // Button size
          shape: RoundedRectangleBorder(
            borderRadius:widget.borderRadius ?? BorderRadius.circular(14),
            side: widget.border != null ? BorderSide(color: widget.border!.top.color) : BorderSide.none, // Button border
          ),
        ),
        child: Row(
          mainAxisAlignment:  widget.title != null  ?  widget.showCenter == null? MainAxisAlignment.spaceBetween:MainAxisAlignment.center:MainAxisAlignment.center,
          children: [
            widget.picture != null?
            SvgPicture.asset(widget.picture!,height: widget.pictureHeight!,color:  widget.pictureColor,):const SizedBox.shrink(),
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





    return InkWell(
      onTap: widget.onTap,
      child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.color ?? AppTheme.buttonColor,
            borderRadius: BorderRadius.circular(4),
            border: widget.border,
          ),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title!,
                style: TextStyle(
                    color: widget.titleColor ?? AppTheme.whiteColor,
                    fontSize: size.height*.018,
                    fontWeight: FontWeight.w500),
              ),
            ],
          )),
    );
  }
}
