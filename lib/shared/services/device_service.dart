import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/device_info.dart';

/// Service for detecting device information and platform
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  DeviceInfo? _deviceInfo;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get current device information
  DeviceInfo? get deviceInfo => _deviceInfo;

  /// Check if running on Wear OS
  bool get isWearOS => _deviceInfo?.isWatch ?? false;

  /// Check if running on phone
  bool get isPhone => _deviceInfo?.isPhone ?? false;

  /// Initialize device detection
  Future<void> initialize() async {
    try {
      debugPrint('DeviceService: Initializing device detection...');
      _deviceInfo = await _detectDevice();
      debugPrint('DeviceService: Device detected: $_deviceInfo');
    } catch (e) {
      debugPrint('DeviceService: Error detecting device: $e');
    }
  }

  /// Detect current device information
  Future<DeviceInfo> _detectDevice() async {
    try {
      if (Platform.isAndroid) {
        return await _detectAndroidDevice();
      } else if (Platform.isIOS) {
        return await _detectIOSDevice();
      } else {
        return _createUnknownDevice();
      }
    } catch (e) {
      debugPrint('DeviceService: Error in device detection: $e');
      return _createUnknownDevice();
    }
  }

  /// Detect Android device information
  Future<DeviceInfo> _detectAndroidDevice() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    
    // Get display metrics
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize;
    final pixelRatio = view.devicePixelRatio;
    
    final screenWidth = size.width / pixelRatio;
    final screenHeight = size.height / pixelRatio;
    
    // Detect if it's a Wear OS device
    final isWatch = await _isWearOSDevice(androidInfo);
    
    return DeviceInfo(
      deviceType: isWatch ? 'wear' : 'mobile',
      model: '${androidInfo.brand} ${androidInfo.model}',
      osVersion: 'Android ${androidInfo.version.release}',
      isWatch: isWatch,
      isPhone: !isWatch,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      pixelRatio: pixelRatio,
    );
  }

  /// Detect iOS device information
  Future<DeviceInfo> _detectIOSDevice() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    
    // Get display metrics
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize;
    final pixelRatio = view.devicePixelRatio;
    
    final screenWidth = size.width / pixelRatio;
    final screenHeight = size.height / pixelRatio;
    
    // Check if it's an Apple Watch
    final isWatch = iosInfo.model.toLowerCase().contains('watch') ||
                    iosInfo.systemName.toLowerCase().contains('watch');
    
    return DeviceInfo(
      deviceType: isWatch ? 'watch' : 'mobile',
      model: iosInfo.model,
      osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
      isWatch: isWatch,
      isPhone: !isWatch,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      pixelRatio: pixelRatio,
    );
  }

  /// Create unknown device info as fallback
  DeviceInfo _createUnknownDevice() {
    // Get basic display metrics
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize;
    final pixelRatio = view.devicePixelRatio;
    
    final screenWidth = size.width / pixelRatio;
    final screenHeight = size.height / pixelRatio;
    
    // Assume it's a watch if the screen is small and square-ish
    final isWatch = screenWidth < 300 && (screenHeight / screenWidth).abs() < 1.5;
    
    return DeviceInfo(
      deviceType: isWatch ? 'wear' : 'mobile',
      model: 'Unknown Device',
      osVersion: 'Unknown OS',
      isWatch: isWatch,
      isPhone: !isWatch,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      pixelRatio: pixelRatio,
    );
  }

  /// Check if Android device is Wear OS
  Future<bool> _isWearOSDevice(AndroidDeviceInfo androidInfo) async {
    try {
      // Method 1: Check system features for Wear OS
      if (androidInfo.systemFeatures.any((feature) => 
          feature.contains('watch') || 
          feature.contains('wear') ||
          feature.contains('android.hardware.type.watch'))) {
        return true;
      }

      // Method 2: Check device characteristics
      final characteristics = androidInfo.systemFeatures
          .where((feature) => feature.contains('android.software'))
          .toList();
      
      if (characteristics.any((char) => 
          char.contains('watch') || char.contains('wear'))) {
        return true;
      }

      // Method 3: Check screen size (Wear OS devices typically have small, square screens)
      final view = PlatformDispatcher.instance.views.first;
      final size = view.physicalSize;
      final pixelRatio = view.devicePixelRatio;
      
      final screenWidth = size.width / pixelRatio;
      final screenHeight = size.height / pixelRatio;
      final aspectRatio = screenHeight / screenWidth;
      
      // Wear OS devices usually have screens smaller than 300dp and close to square
      if (screenWidth < 300 && aspectRatio > 0.8 && aspectRatio < 1.25) {
        return true;
      }

      // Method 4: Check model names that indicate Wear OS
      final model = androidInfo.model.toLowerCase();
      final brand = androidInfo.brand.toLowerCase();
      
      final wearKeywords = [
        'watch', 'wear', 'galaxy watch', 'ticwatch', 'fossil gen',
        'moto 360', 'huawei watch', 'tag heuer', 'michael kors'
      ];
      
      if (wearKeywords.any((keyword) => 
          model.contains(keyword) || brand.contains(keyword))) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('DeviceService: Error checking Wear OS: $e');
      // Fallback to screen size detection
      final view = PlatformDispatcher.instance.views.first;
      final size = view.physicalSize;
      final pixelRatio = view.devicePixelRatio;
      
      final screenWidth = size.width / pixelRatio;
      return screenWidth < 300;
    }
  }

  /// Get a detailed device report
  String getDeviceReport() {
    if (_deviceInfo == null) {
      return 'Device information not available';
    }

    final info = _deviceInfo!;
    return '''
Device Type: ${info.deviceType}
Model: ${info.model}
OS Version: ${info.osVersion}
Is Watch: ${info.isWatch}
Is Phone: ${info.isPhone}
Screen: ${info.screenWidth.toStringAsFixed(1)} x ${info.screenHeight.toStringAsFixed(1)} dp
Pixel Ratio: ${info.pixelRatio.toStringAsFixed(2)}
''';
  }
}