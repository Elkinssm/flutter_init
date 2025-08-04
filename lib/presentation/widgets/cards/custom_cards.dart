import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomCards extends StatelessWidget {
  final double sizeTextButton;
  final String title;
  final String subtitle;
  final String textButton;
  final VoidCallback action;

  const CustomCards({
    super.key,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.textButton,
    required this.sizeTextButton,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 175,
      child: Card(
        color: Color.fromRGBO(229, 240, 246, 1),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                CustomTitleText(
                  text: title,
                  size: 19,
                  color: Color.fromRGBO(11, 25, 38, 1),
                ),
                SizedBox(height: 3),
                CustomText(
                  text: subtitle,
                  size: 12,
                  fontWeight: FontWeight.normal,
                ),
                SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: action,
                    child: CustomText(
                      color: Color.fromRGBO(27, 71, 56, 1),
                      text: textButton,
                      size: sizeTextButton,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
