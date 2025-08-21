import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  final bool isPassword;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.isPassword = false,
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
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: Colors.transparent),
    );

    return SizedBox(
      height: 43,
      width: double.infinity,
      child: TextFormField(
        onTapOutside: (event) => FocusNode().unfocus(),
        obscureText: _obscure,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          enabledBorder: border,
          filled: true,
          fillColor: Colors.white,
          focusedBorder: border,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: _obscure ? Color.fromRGBO(138, 149, 151, 1) : null,
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                  : null,
        ),
      ),
    );
  }
}
