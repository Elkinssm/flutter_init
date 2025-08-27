import 'package:flutter/material.dart';

bool isPhone(BuildContext c) => MediaQuery.of(c).size.shortestSide < 600;
bool isSmallTablet(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 600 && s < 840;
}
bool isLargeTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 840;

double wp(BuildContext c, double p) => MediaQuery.of(c).size.width * p;
double hp(BuildContext c, double p) => MediaQuery.of(c).size.height * p;

double ts(BuildContext c, double base) {
  if (isLargeTablet(c)) return base * 1.35;
  if (isSmallTablet(c)) return base * 1.18;
  return base;
}

Widget maxWidthCenter({required BuildContext context, required Widget child, double max = 720}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}
