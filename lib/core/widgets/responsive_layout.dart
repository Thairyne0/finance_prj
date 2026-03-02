import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletBreakpoint) return ScreenType.desktop;
    if (width >= mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;

  /// Larghezza massima del contenuto in base allo screen type
  static double contentMaxWidth(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 700;
      case ScreenType.desktop:
        return 1100;
    }
  }

  /// Numero di colonne per griglie adattive
  static int gridColumns(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
    }
  }

  /// Padding orizzontale adattivo
  static double horizontalPadding(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 20;
      case ScreenType.tablet:
        return 32;
      case ScreenType.desktop:
        return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Wrapper che centra e limita il contenuto in base al breakpoint
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveLayout.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}

