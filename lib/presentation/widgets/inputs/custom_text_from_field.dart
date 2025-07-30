import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: Colors.transparent),
    );

    return TextFormField(
      onTapOutside: (event) => FocusNode().unfocus(),
      obscureText: obscureText!,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        enabledBorder: border,
        filled: true,
        fillColor: Colors.white,
        focusedBorder: border,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
