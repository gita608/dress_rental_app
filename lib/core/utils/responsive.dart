import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static int catalogGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double maxFormWidth(BuildContext context) =>
      isTablet(context) ? 480 : double.infinity;

  static double splashLogoHeight(BuildContext context) =>
      isTablet(context) ? 220 : 180;

  static double itemDetailImageHeight(BuildContext context) =>
      isTablet(context) ? 450 : 400;
}
