import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared/services/communication_service.dart';
import 'shared/services/device_service.dart';
import 'shared/utils/app_theme.dart';
import 'mobile/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DeviceService().initialize();
  await CommunicationService().initialize();
  
  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WearOS Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(
        GoogleFonts.poppinsTextTheme(),
      ),
      home: const MobileHomeScreen(),
    );
  }
}