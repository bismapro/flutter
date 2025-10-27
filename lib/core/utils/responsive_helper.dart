import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double smallScreenSize = 360;
  static const double mediumScreenSize = 600;
  static const double largeScreenSize = 900;
  static const double extraLargeScreenSize = 1200;

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumScreenSize;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumScreenSize &&
        MediaQuery.of(context).size.width < largeScreenSize;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeScreenSize &&
        MediaQuery.of(context).size.width < extraLargeScreenSize;
  }

  static bool isExtraLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLargeScreenSize;
  }

  static double adaptiveTextSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isMediumScreen(context)) {
      return baseSize;
    } else if (isLargeScreen(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }
}
