import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

enum AppInputSurface { solid, translucent }

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final Color? iconColor;
  final bool? obscureText;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? errorText;
  final String? successText;
  final AppInputSurface surface;
  final TextAlign textAlign;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.icon,
    this.iconColor,
    this.obscureText = false,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.errorText,
    this.successText,
    this.surface = AppInputSurface.solid,
    this.textAlign = TextAlign.start,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscure = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText!;
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText && !widget.isPassword) {
      _obscure = widget.obscureText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintFs = ts(context, 16);
    final iconSize = ts(context, 20);
    final brand = const Color.fromRGBO(217, 73, 41, 1);
    final success = const Color.fromRGBO(79, 166, 38, 1);
    final error = const Color(0xFFE53935);
    final text = const Color(0xFF0B1926);
    final muted = const Color(0xFF9CA3AF);
    final passwordMuted = const Color.fromRGBO(138, 149, 151, 1);
    final isFocused = _focusNode.hasFocus;
    final isTranslucent = widget.surface == AppInputSurface.translucent;
    final subtleBorder =
        isTranslucent
            ? const Color.fromRGBO(255, 255, 255, 0.25)
            : const Color(0xFFE5E7EB);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasSuccess =
        !hasError &&
        widget.successText != null &&
        widget.successText!.isNotEmpty;
    final normalFill =
        widget.readOnly
            ? const Color.fromRGBO(245, 245, 245, 1)
            : hasError
            ? const Color.fromRGBO(255, 245, 245, 0.96)
            : hasSuccess
            ? const Color.fromRGBO(246, 253, 244, 0.96)
            : isFocused
            ? Colors.white
            : isTranslucent
            ? const Color.fromRGBO(255, 255, 255, 0.24)
            : Colors.white;
    final hintColor =
        isTranslucent && !isFocused && !hasError && !hasSuccess
            ? Colors.white.withValues(alpha: 0.82)
            : muted;
    final stateColor =
        hasError
            ? error
            : hasSuccess
            ? success
            : isFocused
            ? brand
            : muted;
    final Widget? trailingIcon =
        widget.suffixIcon ??
        (hasError
            ? Icon(Icons.cancel_outlined, color: error, size: iconSize)
            : hasSuccess
            ? Icon(Icons.check_circle_outline, color: success, size: iconSize)
            : null);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      maxLength: widget.maxLength,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      obscureText: _obscure,
      cursorColor: brand,
      style: GoogleFonts.inter(
        color: text,
        fontSize: ts(context, 16),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: isPhone(context) ? 16 : 18,
          vertical: isPhone(context) ? 14 : 16,
        ),
        enabledBorder: border(
          hasError
              ? error
              : hasSuccess
              ? success
              : subtleBorder,
        ),
        disabledBorder: border(subtleBorder),
        errorBorder: border(error, 1.2),
        filled: true,
        fillColor: normalFill,
        focusedBorder: border(
          hasError
              ? error
              : hasSuccess
              ? success
              : brand,
          1.4,
        ),
        focusedErrorBorder: border(error, 1.4),
        errorText: widget.errorText,
        errorStyle: GoogleFonts.inter(
          color: error,
          fontSize: ts(context, 12),
          fontWeight: FontWeight.w600,
        ),
        helperText: hasSuccess ? widget.successText : null,
        helperStyle: GoogleFonts.inter(
          color: success,
          fontSize: ts(context, 12),
          fontWeight: FontWeight.w600,
        ),
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: hintFs,
          color: hintColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon:
            widget.icon != null
                ? Icon(
                  widget.icon,
                  size: iconSize,
                  color:
                      hasError || hasSuccess || isFocused
                          ? stateColor
                          : widget.iconColor,
                )
                : null,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: iconSize,
                  ),
                  color:
                      hasError || hasSuccess || isFocused
                          ? stateColor
                          : passwordMuted,
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
                : trailingIcon,
      ),
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }
}
