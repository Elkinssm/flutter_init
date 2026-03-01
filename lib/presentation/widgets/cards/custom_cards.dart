import 'package:coach_app/presentation/widgets/widgets.dart';
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Card(
        color: Color.fromRGBO(229, 240, 246, 1),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: title,
                  size: 20,
                  fontWeight: FontWeight.w800,
                  color: Color.fromRGBO(11, 25, 38, 1),
                ),
                CustomText(
                  text: subtitle,
                  size: 12,
                  fontWeight: FontWeight.w400,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth =
                        constraints.hasBoundedWidth
                            ? constraints.maxWidth
                            : null;
                    return SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: action,
                        style: ElevatedButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: CustomText(
                          color: Color.fromRGBO(27, 71, 56, 1),
                          text: textButton,
                          size: sizeTextButton,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
