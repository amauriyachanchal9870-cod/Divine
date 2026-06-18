import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class NoSpaceAtStartFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    return newValue;
  }
}

class CommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool? obSecure;
  final bool readOnly;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final VoidCallback? onEditingCompleted;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isMulti;
  final bool autofocus;
  final bool enabled;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final String? prefixText;            // ✅ Added
  final TextStyle? prefixStyle;        // ✅ Added
  final Widget? suffixIcon;
  final Widget? prefix;
  final String? prefixImg;
  final double? prefixImgSize;
  final Color? cursorErrorColor;
  final Color? backgroundColor;
  final bool useBorder;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? prefixImgColor;
  final Color? textColor;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const CommonTextField({
    super.key,
    this.controller,
    this.validator,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obSecure,
    this.onTap,
    this.isMulti = false,
    this.readOnly = false,
    this.autofocus = false,
    this.errorText,
    this.prefixText,
    this.prefixStyle, // ✅ Added
    required this.hintText,
    this.suffixIcon,
    this.prefix,
    this.prefixImg,
    this.prefixImgSize,
    this.cursorErrorColor,
    this.enabled = true,
    this.onEditingCompleted,
    this.onChanged,
    this.onSaved,
    this.labelText,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.backgroundColor,
    this.useBorder = true,
    this.borderColor,
    this.borderRadius = 8.0,
    this.textStyle,
    this.prefixImgColor,
    this.textColor,
    this.maxLength,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: widget.textStyle ??
          GoogleFonts.poppins(
            color: widget.textColor ?? AppTheme.secondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
      textAlign: TextAlign.start,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      textCapitalization: TextCapitalization.sentences,
      cursorErrorColor: widget.cursorErrorColor,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: widget.onFieldSubmitted,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingCompleted,
      obscureText: widget.obSecure ?? false,
      minLines: widget.isMulti ? 4 : 1,
      maxLines: widget.isMulti ? 4 : 1,
      onTap: widget.onTap,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: AppTheme.themeColor,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        filled: true,
        fillColor: widget.backgroundColor ?? Colors.white,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.subHadingColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        prefixText: widget.prefixText, // ✅ Now applied
        prefixStyle: widget.prefixStyle ?? GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        prefixIcon: widget.prefixImg != null
            ? Padding(
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: SizedBox(
            width: widget.prefixImgSize ?? 8,
            height: widget.prefixImgSize ?? 8,
            child: Image.asset(
              widget.prefixImg!,
              fit: BoxFit.contain,
              color: widget.prefixImgColor,
            ),
          ),
        )
            : widget.prefix,

        suffixIcon: widget.suffixIcon,

        border: widget.useBorder
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey, width: 1.5),
        )
            : InputBorder.none,

        enabledBorder: widget.useBorder
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey, width: 1.5),
        )
            : InputBorder.none,

        focusedBorder: widget.useBorder
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey, width: 2),
        )
            : InputBorder.none,

        errorBorder: widget.useBorder
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey, width: 1.5),
        )
            : InputBorder.none,

        focusedErrorBorder: widget.useBorder
            ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        )
            : InputBorder.none,
      ),
      validator: widget.validator,
    );
  }
}


class RegisterTextFieldWidget extends StatelessWidget {
  final IconButton? suffixIcon;
  final IconData? prefixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final Color? bgColor;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hint;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputFormatter? digitValue;
  final bool? readOnly;
  final dynamic value = 0;
  final dynamic minLines;
  final dynamic maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final VoidCallback? onTap;
  final length;
  final color;

  const RegisterTextFieldWidget({
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.bgColor,
    this.validator,
    this.suffix,
    this.autofillHints,
    this.prefix,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.length,
    this.digitValue,
    this.color, this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Color(0xFF384953)),
      onTap: onTap,
      onChanged: onChanged,
      readOnly: readOnly!,
      controller: controller,
      obscureText: hint == hint ? obscureText! : false,
      autofillHints: autofillHints,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: AppTheme.primaryColor,
      inputFormatters: [
        ...inputFormatters ?? [],
        LengthLimitingTextInputFormatter(length),
        if(digitValue !=null) digitValue!
      ],
      decoration: InputDecoration(
          hintText: hint,
          focusColor: const Color(0xFF384953),
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF384953),
            textStyle: GoogleFonts.poppins(
              color: const Color(0xFF384953),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            fontSize: 14,
            // fontFamily: 'poppins',
            fontWeight: FontWeight.w300,
          ),
          filled: true,
          fillColor: color,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          // .copyWith(top: maxLines! > 4 ? AddSize.size18 : 0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF384953).withValues(alpha: .24)),
            borderRadius: BorderRadius.circular(6.0),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF384953).withValues(alpha: .24)),
              borderRadius: const BorderRadius.all(Radius.circular(6.0))),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF384953).withValues(alpha: .24), width: 3.0),
              borderRadius: BorderRadius.circular(6.0)),
          suffixIcon: suffixIcon,
          prefixIcon: prefix),
    );
  }
}
