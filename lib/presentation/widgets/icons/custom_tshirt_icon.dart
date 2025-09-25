import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';

enum TshirtStatus { none, present, absent }

class CustomTshirtIcon extends StatelessWidget {
  final int number;
  final double width;
  final double height;
  final TshirtStatus status;
  const CustomTshirtIcon({
    super.key,
    required this.number,
    required this.width,
    required this.height,
    this.status = TshirtStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    // Determine image by status (present=green, absent=yellow, none=blue)
    final String imagePath = switch (status) {
      TshirtStatus.present => 'assets/images/tshirt-icon-green.png',
      TshirtStatus.absent => 'assets/images/tshirt-icon-yellow.png',
      TshirtStatus.none => 'assets/images/tshirt-icon-blue.png',
    };

    // Hint engine to decode near display size to reduce jank/flicker
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final int cacheW = (width * dpr).round();
    final int cacheH = (height * dpr).round();

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              cacheWidth: cacheW > 0 ? cacheW : null,
              cacheHeight: cacheH > 0 ? cacheH : null,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: height * 0.07),
                child: CustomText(
                  text: '$number',
                  fontWeight: FontWeight.w700,
                  size: width * 0.36,
                  color: const Color.fromRGBO(238, 248, 255, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
