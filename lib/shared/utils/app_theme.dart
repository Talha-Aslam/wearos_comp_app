import 'package:flutter/material.dart';

/// Theme constants for the app
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  
  // Status colors
  static const Color connectedColor = Color(0xFF10B981);
  static const Color disconnectedColor = Color(0xFFEF4444);
  static const Color pendingColor = Color(0xFFF59E0B);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF06B6D4),
    Color(0xFF0891B2),
  ];

  // Light theme
  static ThemeData lightTheme(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
    );
  }

  // Dark theme for Wear OS
  static ThemeData darkTheme(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
    );
  }

  // Connection status color
  static Color getConnectionColor(bool isConnected) {
    return isConnected ? connectedColor : disconnectedColor;
  }

  // Status indicator color based on connection state
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return connectedColor;
      case 'not paired':
      case 'not supported':
      case 'error':
        return disconnectedColor;
      case 'paired but not reachable':
      case 'checking...':
        return pendingColor;
      default:
        return pendingColor;
    }
  }
}

/// Constants for the app
class AppConstants {
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Connection timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration messageTimeout = Duration(seconds: 5);
  
  // Sizes
  static const double watchButtonSize = 60.0;
  static const double phoneButtonSize = 80.0;
  static const double watchPadding = 8.0;
  static const double phonePadding = 16.0;
  
  // Border radius
  static const double borderRadius = 12.0;
  static const double watchBorderRadius = 8.0;
}

/// Responsive utilities
class ResponsiveUtils {
  /// Check if the device screen is small (watch-like)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 300 || size.height < 300;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    return isSmallScreen(context)
        ? const EdgeInsets.all(AppConstants.watchPadding)
        : const EdgeInsets.all(AppConstants.phonePadding);
  }

  /// Get appropriate button size based on screen size
  static double getButtonSize(BuildContext context) {
    return isSmallScreen(context)
        ? AppConstants.watchButtonSize
        : AppConstants.phoneButtonSize;
  }

  /// Get appropriate border radius based on screen size
  static double getBorderRadius(BuildContext context) {
    return isSmallScreen(context)
        ? AppConstants.watchBorderRadius
        : AppConstants.borderRadius;
  }

  /// Get text scale factor for different screen sizes
  static double getTextScale(BuildContext context) {
    return isSmallScreen(context) ? 0.8 : 1.0;
  }
}