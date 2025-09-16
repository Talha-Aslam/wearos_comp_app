import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Import all platform apps
import 'main_mobile.dart' as mobile;
import 'main_wear.dart' as wear;
import 'main_ios.dart' as ios;
import 'main_watchos.dart' as watchos;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect the platform and launch appropriate app
  final platformType = await _detectPlatformType();

  switch (platformType) {
    case PlatformType.wearOS:
      debugPrint('⌚ DETECTED: Wear OS device - launching wear app');
      wear.main();
      break;
    case PlatformType.watchOS:
      debugPrint('⌚ DETECTED: watchOS device - launching watchOS app');
      watchos.main();
      break;
    case PlatformType.iOS:
      debugPrint('📱 DETECTED: iOS device - launching iOS app');
      ios.main();
      break;
    case PlatformType.android:
    default:
      debugPrint('📱 DETECTED: Android mobile device - launching mobile app');
      mobile.main();
      break;
  }
}

enum PlatformType {
  android,
  wearOS,
  iOS,
  watchOS,
}

/// Detect the current platform type with enhanced detection
Future<PlatformType> _detectPlatformType() async {
  try {
    if (!kIsWeb && Platform.isAndroid) {
      final isWear = await _detectWearDevice();
      return isWear ? PlatformType.wearOS : PlatformType.android;
    } else if (!kIsWeb && Platform.isIOS) {
      final isWatch = await _detectWatchOSDevice();
      return isWatch ? PlatformType.watchOS : PlatformType.iOS;
    } else {
      return PlatformType.android; // Default fallback
    }
  } catch (e) {
    debugPrint('❌ Error detecting platform type: $e');
    return PlatformType.android; // Default fallback
  }
}

/// Detect if we're running on a Wear OS device
Future<bool> _detectWearDevice() async {
  try {
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

    debugPrint('🔍 Android Device Detection:');
    debugPrint('   Model: ${androidInfo.model}');
    debugPrint('   Brand: ${androidInfo.brand}');
    debugPrint('   Product: ${androidInfo.product}');
    debugPrint('   Manufacturer: ${androidInfo.manufacturer}');
    debugPrint('   Is Wear: $isWear');

    return isWear;
  } catch (e) {
    debugPrint('❌ Error detecting Wear OS device: $e');
    return false;
  }
}

/// Detect if we're running on a watchOS device
Future<bool> _detectWatchOSDevice() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;

    // Check for Apple Watch indicators
    final model = iosInfo.model.toLowerCase();
    final name = iosInfo.name.toLowerCase();
    final systemName = iosInfo.systemName.toLowerCase();

    // Apple Watch identifiers
    final watchIndicators = [
      'watch',
      'apple watch',
      'watchos',
      'series',
    ];

    final deviceString = '$model $name $systemName';
    final isWatch =
        watchIndicators.any((indicator) => deviceString.contains(indicator)) ||
            systemName.contains('watchos');

    debugPrint('🔍 iOS Device Detection:');
    debugPrint('   Model: ${iosInfo.model}');
    debugPrint('   Name: ${iosInfo.name}');
    debugPrint('   System: ${iosInfo.systemName}');
    debugPrint('   System Version: ${iosInfo.systemVersion}');
    debugPrint('   Is Watch: $isWatch');

    return isWatch;
  } catch (e) {
    debugPrint('❌ Error detecting watchOS device: $e');
    return false;
  }
}
