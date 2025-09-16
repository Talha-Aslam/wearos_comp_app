import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../shared/services/communication_service.dart';
import '../../shared/services/device_service.dart';
import '../../shared/models/app_message.dart';
import '../../shared/models/device_info.dart' as DeviceModels;

class WatchOSHomeScreen extends StatefulWidget {
  final CommunicationService communicationService;
  final DeviceService deviceService;

  const WatchOSHomeScreen({
    super.key,
    required this.communicationService,
    required this.deviceService,
  });

  @override
  State<WatchOSHomeScreen> createState() => _WatchOSHomeScreenState();
}

class _WatchOSHomeScreenState extends State<WatchOSHomeScreen> {
  final List<AppMessage> _messages = [];
  StreamSubscription<AppMessage>? _messageSubscription;
  StreamSubscription<DeviceModels.ConnectionState>? _connectionSubscription;

  DeviceModels.DeviceInfo? _deviceInfo;
  DeviceModels.ConnectionState _connectionState = DeviceModels.ConnectionState(
    isSupported: false,
    isPaired: false,
    isReachable: false,
    isConnected: false,
    status: 'Initializing...',
    lastUpdate: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize communication service
      await widget.communicationService.initialize();

      // Initialize device service
      await widget.deviceService.initialize();
      _deviceInfo = widget.deviceService.deviceInfo;

      // Listen to messages
      _messageSubscription = widget.communicationService.messageStream.listen(
        (message) {
          setState(() {
            _messages.insert(0, message);
          });
        },
      );

      // Listen to connection changes
      _connectionSubscription =
          widget.communicationService.connectionStream.listen(
        (state) {
          setState(() {
            _connectionState = state;
          });
        },
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendPredefinedMessage(String message) async {
    final appMessage = AppMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageTypes.data,
      content: message,
      timestamp: DateTime.now(),
      sender: 'watchOS-${_deviceInfo?.model ?? 'AppleWatch'}',
    );

    final success = await widget.communicationService.sendMessage(appMessage);

    if (success) {
      setState(() {
        _messages.insert(0, appMessage);
      });

      // Provide haptic feedback on watch
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for watch optimization
    final size = MediaQuery.of(context).size;
    final isSmallWatch = size.width < 200;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Compact header
            _buildWatchHeader(isSmallWatch),

            // Connection indicator
            _buildConnectionIndicator(isSmallWatch),

            // Quick action buttons
            _buildQuickActions(isSmallWatch),

            // Recent messages
            Expanded(
              child: _buildMessagesList(isSmallWatch),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchHeader(bool isSmallWatch) {
    return Container(
      padding: EdgeInsets.all(isSmallWatch ? 8.0 : 12.0),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.device_phone_portrait,
            color: CupertinoColors.systemBlue,
            size: isSmallWatch ? 24 : 32,
          ),
          SizedBox(height: isSmallWatch ? 4 : 8),
          Text(
            'Companion',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: isSmallWatch ? 14 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(bool isSmallWatch) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallWatch ? 8.0 : 16.0,
        vertical: 4.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallWatch ? 8.0 : 12.0,
        vertical: isSmallWatch ? 4.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: _connectionState.isConnected
            ? CupertinoColors.systemGreen.withOpacity(0.2)
            : CupertinoColors.systemOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isSmallWatch ? 8 : 12),
        border: Border.all(
          color: _connectionState.isConnected
              ? CupertinoColors.systemGreen
              : CupertinoColors.systemOrange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _connectionState.isConnected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_triangle,
            color: _connectionState.isConnected
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemOrange,
            size: isSmallWatch ? 12 : 16,
          ),
          SizedBox(width: isSmallWatch ? 4 : 8),
          Flexible(
            child: Text(
              _connectionState.isConnected ? 'iPhone' : 'Disconnected',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: isSmallWatch ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isSmallWatch) {
    final buttonSize = isSmallWatch ? 60.0 : 80.0;
    final fontSize = isSmallWatch ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallWatch ? 8.0 : 16.0,
        vertical: isSmallWatch ? 8.0 : 12.0,
      ),
      child: Column(
        children: [
          // First row of buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                '👋',
                'Hello',
                () => _sendPredefinedMessage('Hello from Apple Watch!'),
                buttonSize,
                fontSize,
              ),
              _buildActionButton(
                '✅',
                'OK',
                () => _sendPredefinedMessage('OK'),
                buttonSize,
                fontSize,
              ),
              _buildActionButton(
                '🆘',
                'Help',
                () => _sendPredefinedMessage('Need help'),
                buttonSize,
                fontSize,
              ),
            ],
          ),
          SizedBox(height: isSmallWatch ? 8 : 12),
          // Second row of buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                '📍',
                'Location',
                () => _sendPredefinedMessage('Sharing location'),
                buttonSize,
                fontSize,
              ),
              _buildActionButton(
                '🔋',
                'Battery',
                () => _sendPredefinedMessage('Battery status: Good'),
                buttonSize,
                fontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String emoji,
    String label,
    VoidCallback onPressed,
    double size,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: CupertinoColors.systemGrey,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: fontSize + 6),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: fontSize - 2,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(bool isSmallWatch) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_2,
              size: isSmallWatch ? 32 : 48,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: isSmallWatch ? 8 : 16),
            Text(
              'No messages',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: isSmallWatch ? 12 : 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap buttons to send',
              style: TextStyle(
                color: CupertinoColors.systemGrey2,
                fontSize: isSmallWatch ? 10 : 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isSmallWatch ? 8 : 16),
      itemCount: _messages.length > 5 ? 5 : _messages.length, // Limit for watch
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isFromSelf = message.sender?.contains('watchOS') ?? false;

        return Container(
          margin: EdgeInsets.symmetric(vertical: isSmallWatch ? 2 : 4),
          child: Row(
            mainAxisAlignment:
                isFromSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isFromSelf) ...[
                Icon(
                  CupertinoIcons.device_phone_portrait,
                  size: isSmallWatch ? 12 : 16,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(width: isSmallWatch ? 4 : 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallWatch ? 8 : 12,
                    vertical: isSmallWatch ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFromSelf
                        ? CupertinoColors.systemBlue
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(isSmallWatch ? 8 : 12),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: isSmallWatch ? 10 : 12,
                    ),
                  ),
                ),
              ),
              if (isFromSelf) ...[
                SizedBox(width: isSmallWatch ? 4 : 8),
                Icon(
                  CupertinoIcons.time,
                  size: isSmallWatch ? 12 : 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
