import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/services/communication_service.dart';
import '../shared/services/device_service.dart';
import 'ios/screens/ios_home_screen.dart';

void main() {
  runApp(const IOSCompanionApp());
}

class IOSCompanionApp extends StatelessWidget {
  const IOSCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services for iOS
    final communicationService = CommunicationService();
    final deviceService = DeviceService();

    return MaterialApp(
      title: 'Companion App',
      debugShowCheckedModeBanner: false,
      theme: _buildIOSTheme(),
      home: IOSHomeScreen(
        communicationService: communicationService,
        deviceService: deviceService,
      ),
    );
  }

  ThemeData _buildIOSTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: CupertinoColors.systemBackground,
        foregroundColor: CupertinoColors.label,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.systemBlue,
          foregroundColor: CupertinoColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: CupertinoColors.systemBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
