import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/services/communication_service.dart';
import '../shared/services/device_service.dart';
import 'watchos/screens/watchos_home_screen.dart';

void main() {
  runApp(const WatchOSCompanionApp());
}

class WatchOSCompanionApp extends StatelessWidget {
  const WatchOSCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services for watchOS
    final communicationService = CommunicationService();
    final deviceService = DeviceService();

    return MaterialApp(
      title: 'Watch App',
      debugShowCheckedModeBanner: false,
      theme: _buildWatchOSTheme(),
      home: WatchOSHomeScreen(
        communicationService: communicationService,
        deviceService: deviceService,
      ),
    );
  }

  ThemeData _buildWatchOSTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemBlue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.robotoTextTheme().apply(
        bodyColor: CupertinoColors.white,
        displayColor: CupertinoColors.white,
      ),
      scaffoldBackgroundColor: CupertinoColors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: CupertinoColors.black,
        foregroundColor: CupertinoColors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.systemBlue,
          foregroundColor: CupertinoColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // More rounded for watch
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          minimumSize: const Size(80, 44), // Touch-friendly size for watch
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
