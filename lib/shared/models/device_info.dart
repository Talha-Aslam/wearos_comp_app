/// Device information model for runtime device detection
class DeviceInfo {
  final String deviceType;
  final String model;
  final String osVersion;
  final bool isWatch;
  final bool isPhone;
  final double screenWidth;
  final double screenHeight;
  final double pixelRatio;

  const DeviceInfo({
    required this.deviceType,
    required this.model,
    required this.osVersion,
    required this.isWatch,
    required this.isPhone,
    required this.screenWidth,
    required this.screenHeight,
    required this.pixelRatio,
  });

  /// Creates DeviceInfo from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceType: json['deviceType'] as String,
      model: json['model'] as String,
      osVersion: json['osVersion'] as String,
      isWatch: json['isWatch'] as bool,
      isPhone: json['isPhone'] as bool,
      screenWidth: (json['screenWidth'] as num).toDouble(),
      screenHeight: (json['screenHeight'] as num).toDouble(),
      pixelRatio: (json['pixelRatio'] as num).toDouble(),
    );
  }

  /// Converts DeviceInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType,
      'model': model,
      'osVersion': osVersion,
      'isWatch': isWatch,
      'isPhone': isPhone,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'pixelRatio': pixelRatio,
    };
  }

  @override
  String toString() {
    return 'DeviceInfo(type: $deviceType, model: $model, os: $osVersion, isWatch: $isWatch)';
  }
}

/// Connection state for watch connectivity
class ConnectionState {
  final bool isSupported;
  final bool isPaired;
  final bool isReachable;
  final bool isConnected;
  final String status;
  final DateTime lastUpdate;

  const ConnectionState({
    required this.isSupported,
    required this.isPaired,
    required this.isReachable,
    required this.isConnected,
    required this.status,
    required this.lastUpdate,
  });

  /// Creates ConnectionState from JSON
  factory ConnectionState.fromJson(Map<String, dynamic> json) {
    return ConnectionState(
      isSupported: json['isSupported'] as bool,
      isPaired: json['isPaired'] as bool,
      isReachable: json['isReachable'] as bool,
      isConnected: json['isConnected'] as bool,
      status: json['status'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  /// Converts ConnectionState to JSON
  Map<String, dynamic> toJson() {
    return {
      'isSupported': isSupported,
      'isPaired': isPaired,
      'isReachable': isReachable,
      'isConnected': isConnected,
      'status': status,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  ConnectionState copyWith({
    bool? isSupported,
    bool? isPaired,
    bool? isReachable,
    bool? isConnected,
    String? status,
    DateTime? lastUpdate,
  }) {
    return ConnectionState(
      isSupported: isSupported ?? this.isSupported,
      isPaired: isPaired ?? this.isPaired,
      isReachable: isReachable ?? this.isReachable,
      isConnected: isConnected ?? this.isConnected,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  String toString() {
    return 'ConnectionState(connected: $isConnected, status: $status)';
  }
}