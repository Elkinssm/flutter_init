import 'package:flutter/material.dart';
/*-----------------------------------------------------------------------------------*/

// phones
bool isSmallPhone(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 320 && s < 360;
}

bool isPhone(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 360 && s < 412;
}

bool isBigPhone(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 412 && s < 600;
}

/*-----------------------------------------------------------------------------------*/

// tablets
bool isSmallTablet(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 600 && s < 800;
}

bool isMediumTablet(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 800 && s < 1024;
}

bool isLargeTablet(BuildContext c) {
  final s = MediaQuery.of(c).size.shortestSide;
  return s >= 1024 && s <= 1280;
}

/*-----------------------------------------------------------------------------------*/

// notches/barras
double _safeW(BuildContext c) {
  final mq = MediaQuery.of(c);
  return mq.size.width - mq.viewPadding.left - mq.viewPadding.right;
}

double _safeH(BuildContext c) {
  final mq = MediaQuery.of(c);
  return mq.size.height - mq.viewPadding.top - mq.viewPadding.bottom;
}

double swp(BuildContext c, double p) => _safeW(c) * p;
double shp(BuildContext c, double p) => _safeH(c) * p;

/*-----------------------------------------------------------------------------------*/

// ratio / hairline
double _dpr(BuildContext c) => MediaQuery.devicePixelRatioOf(c);
double onePhysicalPx(BuildContext c) => 1 / _dpr(c);

/*-----------------------------------------------------------------------------------*/

// sizes
double _w(BuildContext c) => MediaQuery.sizeOf(c).width;
double _h(BuildContext c) => MediaQuery.sizeOf(c).height;

double wp(BuildContext c, double p) => _w(c) * p;
double hp(BuildContext c, double p) => _h(c) * p;

/*-----------------------------------------------------------------------------------*/

// text
double ts(BuildContext c, double base) {
  final scaler = MediaQuery.textScalerOf(c);
  double factor;

  if (isLargeTablet(c)) {
    factor = 1.6;
  } else if (isMediumTablet(c)) {
    factor = 1.25;
  } else if (isSmallTablet(c)) {
    factor = 1.15;
  } else if (isBigPhone(c)) {
    factor = 1.05;
  } else if (isSmallPhone(c)) {
    factor = 0.95;
  } else {
    factor = 1.0;
  }

  final scaled = scaler.scale(base * factor);
  return scaled.clamp(base * 0.85, base * 1.6);
}

/*-----------------------------------------------------------------------------------*/

Widget maxWidthCenter({
  required BuildContext context,
  required Widget child,
  double max = 720,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}
