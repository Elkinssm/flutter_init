import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  final bool isPassword;
  final TextEditingController? controller;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText!;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    final hintFs = ts(context, 16);
    final iconSize = ts(context, 20);

    return TextFormField(
      controller: widget.controller,
      onTapOutside: (event) => FocusNode().unfocus(),
      obscureText: _obscure,
      style: GoogleFonts.inter(fontSize: ts(context, 16)),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isPhone(context) ? 15 : 18,
          vertical: isPhone(context) ? 8 : 18,
        ),
        enabledBorder: border,
        filled: true,
        fillColor: Colors.white,
        focusedBorder: border,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: hintFs,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon:
            widget.icon != null ? Icon(widget.icon, size: iconSize) : null,
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
                      _obscure ? const Color.fromRGBO(138, 149, 151, 1) : null,
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
                : null,
      ),
    );
  }
}
