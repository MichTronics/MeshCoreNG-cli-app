import 'package:flutter/material.dart';

enum MeshWindowClass { mobile, tablet, desktop }

class MeshResponsive {
  const MeshResponsive._();

  // Shared breakpoints keep Android phone/tablet behavior explicit while
  // preserving the wider desktop layout used on Linux and Windows.
  static const double mobileMax = 700;
  static const double tabletMax = 1100;

  static MeshWindowClass classForWidth(double width) {
    if (width < mobileMax) return MeshWindowClass.mobile;
    if (width <= tabletMax) return MeshWindowClass.tablet;
    return MeshWindowClass.desktop;
  }

  static MeshWindowClass of(BuildContext context) {
    return classForWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isMobile(BuildContext context) {
    return of(context) == MeshWindowClass.mobile;
  }

  static bool isDesktop(BuildContext context) {
    return of(context) == MeshWindowClass.desktop;
  }

  static double pagePadding(BuildContext context) {
    return switch (of(context)) {
      MeshWindowClass.mobile => 8,
      MeshWindowClass.tablet => 12,
      MeshWindowClass.desktop => 16,
    };
  }

  static double gap(BuildContext context) {
    return switch (of(context)) {
      MeshWindowClass.mobile => 8,
      MeshWindowClass.tablet => 10,
      MeshWindowClass.desktop => 12,
    };
  }
}
