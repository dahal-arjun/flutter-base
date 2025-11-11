import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Utility class for responsive design
/// Provides helper methods to check screen size and get responsive values
class AppResponsive {
  /// Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile;
  }

  /// Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isTablet;
  }

  /// Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isDesktop;
  }

  /// Get the current breakpoint name
  static String getBreakpoint(BuildContext context) {
    return ResponsiveBreakpoints.of(context).breakpoint.name ?? 'unknown';
  }

  /// Get responsive value based on screen size
  /// Returns mobile value for mobile, tablet value for tablet, desktop value for desktop
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  /// Returns different padding values based on screen size
  static EdgeInsets responsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue<EdgeInsets>(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );
  }

  /// Get responsive font size
  /// Returns different font sizes based on screen size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue<double>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }

  /// Get responsive grid cross axis count
  /// Returns different column counts for GridView based on screen size and orientation
  static int responsiveGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int? mobileLandscape,
    int? tabletLandscape,
    int? desktopLandscape,
  }) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscapeMode = orientation == Orientation.landscape;

    if (isLandscapeMode) {
      // Use landscape-specific values if provided
      if (isDesktop(context) && desktopLandscape != null) {
        return desktopLandscape;
      } else if (isTablet(context) && tabletLandscape != null) {
        return tabletLandscape;
      } else if (isMobile(context) && mobileLandscape != null) {
        return mobileLandscape;
      }
      // If no landscape values provided, increase columns for landscape
      if (isDesktop(context)) {
        return desktop + 1; // Add one more column in landscape
      } else if (isTablet(context)) {
        return tablet + 1; // Add one more column in landscape
      } else {
        return mobile + 1; // Add one more column in landscape
      }
    }

    return responsiveValue<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive max width for content
  /// Useful for centering content on larger screens
  static double? responsiveMaxWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if screen is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get responsive spacing
  /// Returns different spacing values based on screen size
  static double responsiveSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue<double>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
  }

  /// Get responsive value that considers both screen size and orientation
  /// Useful for layouts that need to adapt to orientation changes
  static T responsiveValueWithOrientation<T>(
    BuildContext context, {
    required T mobilePortrait,
    T? mobileLandscape,
    T? tabletPortrait,
    T? tabletLandscape,
    T? desktopPortrait,
    T? desktopLandscape,
  }) {
    final isLandscapeMode = isLandscape(context);

    if (isDesktop(context)) {
      return isLandscapeMode
          ? (desktopLandscape ?? desktopPortrait ?? mobilePortrait)
          : (desktopPortrait ?? mobilePortrait);
    } else if (isTablet(context)) {
      return isLandscapeMode
          ? (tabletLandscape ?? tabletPortrait ?? mobilePortrait)
          : (tabletPortrait ?? mobilePortrait);
    } else {
      // Mobile
      return isLandscapeMode
          ? (mobileLandscape ?? mobilePortrait)
          : mobilePortrait;
    }
  }

  /// Check if device should use compact layout
  /// Returns true for mobile in portrait or small tablets
  static bool isCompactLayout(BuildContext context) {
    if (isMobile(context)) {
      return isPortrait(context);
    }
    // Tablet in portrait might also need compact layout
    if (isTablet(context) && isPortrait(context)) {
      return screenWidth(context) < 600;
    }
    return false;
  }

  /// Get effective screen width considering orientation
  /// In landscape, width and height are swapped for calculation purposes
  static double effectiveWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width;
  }

  /// Get effective screen height considering orientation
  /// In landscape, width and height are swapped for calculation purposes
  static double effectiveHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height;
  }

  /// Get responsive padding that adapts to orientation
  static EdgeInsets responsivePaddingWithOrientation(
    BuildContext context, {
    EdgeInsets? mobilePortrait,
    EdgeInsets? mobileLandscape,
    EdgeInsets? tabletPortrait,
    EdgeInsets? tabletLandscape,
    EdgeInsets? desktopPortrait,
    EdgeInsets? desktopLandscape,
  }) {
    return responsiveValueWithOrientation<EdgeInsets>(
      context,
      mobilePortrait: mobilePortrait ?? const EdgeInsets.all(16),
      mobileLandscape:
          mobileLandscape ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      tabletPortrait: tabletPortrait ?? const EdgeInsets.all(24),
      tabletLandscape:
          tabletLandscape ??
          const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      desktopPortrait: desktopPortrait ?? const EdgeInsets.all(32),
      desktopLandscape:
          desktopLandscape ??
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    );
  }
}
