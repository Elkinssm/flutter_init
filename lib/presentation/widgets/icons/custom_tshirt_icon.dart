import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';

class CustomTshirtIcon extends StatelessWidget {
  final int number;
  final double width;
  final double height;
  final bool isPresent; // when true, force green shirt (asistencia)
  const CustomTshirtIcon({
    super.key,
    required this.number,
    required this.width,
    required this.height,
    this.isPresent = false,
  });

  @override
  Widget build(BuildContext context) {
    const greenNumbers = {2, 3};
    const yellowNumbers = {1, 4};

    final String imagePath = isPresent
        ? 'assets/images/tshirt-icon-green.png'
        : greenNumbers.contains(number)
            ? 'assets/images/tshirt-icon-green.png'
            : yellowNumbers.contains(number)
                ? 'assets/images/tshirt-icon-yellow.png'
                : 'assets/images/tshirt-icon-blue.png';

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.07),
              child: CustomText(
                text: '$number',
                fontWeight: FontWeight.w700,
                size: width * 0.36,
                color: Color.fromRGBO(238, 248, 255, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
