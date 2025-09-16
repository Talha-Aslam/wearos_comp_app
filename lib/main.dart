import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Import both apps
import 'main_mobile.dart' as mobile;
import 'main_wear.dart' as wear;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect the platform and launch appropriate app
  final isWearDevice = await _detectWearDevice();

  if (isWearDevice) {
    debugPrint('🕰️ DETECTED: Wear OS device - launching wear app');
    wear.main();
  } else {
    debugPrint('📱 DETECTED: Mobile device - launching mobile app');
    mobile.main();
  }
}

/// Detect if we're running on a Wear OS device
Future<bool> _detectWearDevice() async {
  try {
    if (!kIsWeb && Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Check various indicators for Wear OS
      final model = androidInfo.model.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();
      final product = androidInfo.product.toLowerCase();

      // Common Wear OS identifiers
      final wearIndicators = [
        'watch',
        'wear',
        'wearos',
        'galaxy watch',
        'pixel watch',
        'fossil',
        'ticwatch',
        'huawei watch',
        'moto 360',
        'lg watch',
        'sony smartwatch',
        'casio',
        'montblanc',
        'tag heuer',
        'louis vuitton',
        'gwear', // Android emulator
      ];

      final deviceString = '$model $brand $product';
      final isWear =
          wearIndicators.any((indicator) => deviceString.contains(indicator));

      debugPrint('🔍 Device Detection:');
      debugPrint('   Model: ${androidInfo.model}');
      debugPrint('   Brand: ${androidInfo.brand}');
      debugPrint('   Product: ${androidInfo.product}');
      debugPrint('   Manufacturer: ${androidInfo.manufacturer}');
      debugPrint('   Is Wear: $isWear');

      return isWear;
    }
    return false;
  } catch (e) {
    debugPrint('❌ Error detecting device type: $e');
    // Default to mobile if detection fails
    return false;
  }
}
