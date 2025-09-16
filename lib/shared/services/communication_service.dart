import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import '../models/app_message.dart';
import '../models/device_info.dart';
import 'device_service.dart';

/// Service for managing communication between phone and watch
class CommunicationService {
  static final CommunicationService _instance =
      CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal();

  final WatchConnectivity _watchConnectivity = WatchConnectivity();

  // Stream controllers
  final StreamController<AppMessage> _messageController =
      StreamController<AppMessage>.broadcast();
  final StreamController<ConnectionState> _connectionController =
      StreamController<ConnectionState>.broadcast();

  // State
  ConnectionState _connectionState = ConnectionState(
    isSupported: false,
    isPaired: false,
    isReachable: false,
    isConnected: false,
    status: 'Initializing...',
    lastUpdate: DateTime.now(),
  );

  // Flag to track if we've received any messages (indicates working connection)
  bool _hasReceivedMessages = false;

  bool _hasAnnouncedPresence = false;

  // Getters
  Stream<AppMessage> get messageStream => _messageController.stream;
  Stream<ConnectionState> get connectionStream => _connectionController.stream;
  ConnectionState get connectionState => _connectionState;

  /// Initialize the communication service
  Future<void> initialize() async {
    try {
      debugPrint('CommunicationService: Initializing...');

      // Check support
      final isSupported = await _watchConnectivity.isSupported;
      debugPrint('CommunicationService: Supported = $isSupported');

      _updateConnectionState(
        isSupported: isSupported,
        status: isSupported ? 'Supported' : 'Not supported',
      );

      if (!isSupported) {
        debugPrint('CommunicationService: Watch connectivity not supported');
        return;
      }

      // Check pairing and reachability
      await _checkConnectionStatus();

      // Set up listeners
      _setupMessageListener();
      _setupConnectionListeners();

      // Start periodic connection checks
      _startPeriodicChecks();

      // Send initial connection announcement
      _announcePresence();

      debugPrint('CommunicationService: Initialization complete');
    } catch (e) {
      debugPrint('CommunicationService: Error during initialization: $e');
      _updateConnectionState(
        status: 'Error: $e',
      );
    }
  }

  /// Check current connection status
  Future<void> _checkConnectionStatus() async {
    try {
      final isSupported = await _watchConnectivity.isSupported;
      final isPaired = await _watchConnectivity.isPaired;
      final isReachable = await _watchConnectivity.isReachable;

      debugPrint(
          'CommunicationService: Supported = $isSupported, Paired = $isPaired, Reachable = $isReachable');

      // More lenient connection logic - if supported and reachable, consider it connected
      // Pairing status can be unreliable on some platforms
      final isConnected = isSupported && (isReachable || _hasReceivedMessages);

      _updateConnectionState(
        isSupported: isSupported,
        isPaired: isPaired,
        isReachable: isReachable,
        isConnected: isConnected,
        status: _getStatusText(isSupported, isPaired, isReachable, isConnected),
      );
    } catch (e) {
      debugPrint('CommunicationService: Error checking connection status: $e');
      _updateConnectionState(status: 'Error checking status: $e');
    }
  }

  /// Setup message listener
  void _setupMessageListener() {
    _watchConnectivity.messageStream.listen(
      (message) {
        debugPrint('CommunicationService: Received raw message: $message');
        _handleIncomingMessage(message);
      },
      onError: (error) {
        debugPrint('CommunicationService: Message stream error: $error');
      },
    );
  }

  /// Setup connection state listeners
  void _setupConnectionListeners() {
    // Note: WatchConnectivity plugin may not have pairing/reachability streams
    // We'll rely on periodic checks for now
    debugPrint(
        'CommunicationService: Connection listeners setup (using periodic checks)');
  }

  /// Start periodic connection checks
  void _startPeriodicChecks() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_connectionState.isSupported) {
        timer.cancel();
        return;
      }
      _checkConnectionStatus();
    });
  }

  /// Handle incoming messages
  void _handleIncomingMessage(Map<String, dynamic> rawMessage) {
    try {
      // Convert raw message to AppMessage
      final message = _parseMessage(rawMessage);
      debugPrint('CommunicationService: Parsed message: $message');

      // Mark that we've received messages (indicates working connection)
      if (!_hasReceivedMessages) {
        _hasReceivedMessages = true;
        debugPrint(
            'CommunicationService: First message received - updating connection status');
        _checkConnectionStatus(); // Re-check status now that we have evidence of connection
      }

      // Add to stream
      _messageController.add(message);

      // Handle special message types
      if (message.type == MessageTypes.ping) {
        _handlePingMessage(message);
      } else if (message.type == MessageTypes.presence) {
        _handlePresenceMessage(message);
      }
    } catch (e) {
      debugPrint('CommunicationService: Error handling message: $e');
    }
  }

  /// Parse raw message to AppMessage
  AppMessage _parseMessage(Map<String, dynamic> rawMessage) {
    // If the message is already in our format, use it directly
    if (rawMessage.containsKey('id') && rawMessage.containsKey('type')) {
      return AppMessage.fromJson(rawMessage);
    }

    // Otherwise, create a message from the raw data
    return AppMessage(
      id: _generateMessageId(),
      type: rawMessage['type'] as String? ?? MessageTypes.data,
      content: rawMessage['message'] as String? ?? json.encode(rawMessage),
      timestamp: DateTime.now(),
      sender: rawMessage['sender'] as String?,
      data: rawMessage,
    );
  }

  /// Handle ping messages by sending pong
  void _handlePingMessage(AppMessage pingMessage) {
    final pongMessage = AppMessage(
      id: _generateMessageId(),
      type: MessageTypes.pong,
      content: 'Pong response to ${pingMessage.id}',
      timestamp: DateTime.now(),
      sender: 'auto_responder',
    );

    sendMessage(pongMessage);
  }

  /// Handle presence messages by updating connection state
  void _handlePresenceMessage(AppMessage presenceMessage) {
    debugPrint(
        'CommunicationService: Device presence detected: ${presenceMessage.sender}');

    // Update connection state to reflect that the other device is active
    _updateConnectionState(
      isConnected: true,
      status: 'Connected to ${presenceMessage.sender}',
    );

    // Send our own presence back if we haven't announced yet
    if (!_hasAnnouncedPresence) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _announcePresence();
      });
    }
  }

  /// Send a message to the connected device
  Future<bool> sendMessage(AppMessage message) async {
    try {
      debugPrint('CommunicationService: Sending message: $message');

      // For ping and presence messages, try sending even if not officially connected
      final shouldTrySend = _connectionState.isConnected ||
          _connectionState.isSupported &&
              (message.type == MessageTypes.ping ||
                  message.type == MessageTypes.presence);

      if (!shouldTrySend) {
        debugPrint(
            'CommunicationService: Cannot send message - not supported or connected');
        return false;
      }

      await _watchConnectivity.sendMessage(message.toJson());
      debugPrint('CommunicationService: Message sent successfully');
      return true;
    } catch (e) {
      debugPrint('CommunicationService: Error sending message: $e');
      return false;
    }
  }

  /// Send a simple text message
  Future<bool> sendTextMessage(String text,
      {String type = MessageTypes.data}) async {
    final message = AppMessage(
      id: _generateMessageId(),
      type: type,
      content: text,
      timestamp: DateTime.now(),
    );

    return sendMessage(message);
  }

  /// Send a ping message
  Future<bool> sendPing() async {
    final message = AppMessage(
      id: _generateMessageId(),
      type: MessageTypes.ping,
      content: 'Ping from ${DateTime.now()}',
      timestamp: DateTime.now(),
    );

    return sendMessage(message);
  }

  /// Update connection state and notify listeners
  void _updateConnectionState({
    bool? isSupported,
    bool? isPaired,
    bool? isReachable,
    bool? isConnected,
    String? status,
  }) {
    _connectionState = _connectionState.copyWith(
      isSupported: isSupported,
      isPaired: isPaired,
      isReachable: isReachable,
      isConnected: isConnected,
      status: status,
      lastUpdate: DateTime.now(),
    );

    _connectionController.add(_connectionState);
  }

  /// Get human-readable status text
  String _getStatusText(
      bool isSupported, bool isPaired, bool isReachable, bool isConnected) {
    if (!isSupported) return 'Watch connectivity not supported';
    if (!isConnected) {
      if (!isPaired && !isReachable) return 'No watch detected';
      if (!isPaired) return 'Watch not paired';
      if (!isReachable) return 'Watch not reachable';
      return 'Connection issues';
    }
    return 'Connected';
  }

  /// Generate unique message ID
  String _generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return '${timestamp}_$random';
  }

  /// Announce presence to connected devices
  Future<void> _announcePresence() async {
    try {
      if (_hasAnnouncedPresence) {
        return; // Don't announce multiple times
      }

      await Future.delayed(
          const Duration(seconds: 2)); // Small delay to ensure initialization

      final deviceService = DeviceService();
      await deviceService.initialize(); // Make sure it's initialized
      final deviceInfo = deviceService.deviceInfo;

      if (deviceInfo == null) {
        debugPrint(
            'CommunicationService: Device info not available for presence announcement');
        return;
      }

      final announcement = AppMessage(
        id: _generateMessageId(),
        content: 'App started',
        type: MessageTypes.presence,
        timestamp: DateTime.now(),
        sender: deviceInfo.deviceType,
        data: {
          'device_model': deviceInfo.model,
          'device_os': deviceInfo.osVersion,
          'is_watch': deviceInfo.isWatch.toString(),
        },
      );

      await sendMessage(announcement);
      _hasAnnouncedPresence = true;
      debugPrint('CommunicationService: Presence announced');
    } catch (e) {
      debugPrint('CommunicationService: Error announcing presence: $e');
    }
  }

  /// Test connectivity by sending a simple message
  Future<bool> testConnectivity() async {
    try {
      debugPrint('CommunicationService: Testing connectivity...');
      final testMessage = AppMessage(
        id: _generateMessageId(),
        content: 'Connection test',
        type: MessageTypes.ping,
        timestamp: DateTime.now(),
        sender: 'connectivity_test',
      );

      final success = await sendMessage(testMessage);
      debugPrint('CommunicationService: Connectivity test result: $success');

      if (success && !_connectionState.isConnected) {
        // If send succeeded but we think we're not connected, update status
        debugPrint(
            'CommunicationService: Send succeeded - updating connection status to connected');
        _updateConnectionState(
            isConnected: true, status: 'Connected (verified by test)');
      }

      return success;
    } catch (e) {
      debugPrint('CommunicationService: Connectivity test failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _connectionController.close();
  }
}
