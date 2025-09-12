import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearos_comp_app/main_mobile.dart';
import 'package:wearos_comp_app/main_wear.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // Extra detection if watch vs phone
      return const MaterialApp(home: PhoneApp());
    } else {
      return const MaterialApp(home: WearOSApp());
    }
  }
}
