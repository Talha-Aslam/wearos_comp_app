import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../shared/services/communication_service.dart';
import '../../shared/services/device_service.dart';
import '../../shared/models/app_message.dart';
import '../../shared/models/device_info.dart' as DeviceModels;

class IOSHomeScreen extends StatefulWidget {
  final CommunicationService communicationService;
  final DeviceService deviceService;

  const IOSHomeScreen({
    super.key,
    required this.communicationService,
    required this.deviceService,
  });

  @override
  State<IOSHomeScreen> createState() => _IOSHomeScreenState();
}

class _IOSHomeScreenState extends State<IOSHomeScreen> {
  final TextEditingController _messageController = TextEditingController();
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
    _messageController.dispose();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = AppMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageTypes.data,
      content: text,
      timestamp: DateTime.now(),
      sender: 'iOS-${_deviceInfo?.model ?? 'iPhone'}',
    );

    final success = await widget.communicationService.sendMessage(message);

    if (success) {
      setState(() {
        _messages.insert(0, message);
        _messageController.clear();
      });

      // Show iOS-style feedback
      if (mounted) {
        _showSuccessHaptic();
      }
    } else {
      if (mounted) {
        _showErrorAlert();
      }
    }
  }

  void _showSuccessHaptic() {
    HapticFeedback.lightImpact();
  }

  void _showErrorAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Message Failed'),
        content:
            const Text('Unable to send message. Please check your connection.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Companion App'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showConnectionInfo(),
          child: Icon(
            _connectionState.isConnected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_circle,
            color: _connectionState.isConnected
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemOrange,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Device Info Card
            _buildDeviceInfoCard(),

            // Connection Status
            _buildConnectionStatus(),

            // Message Input
            _buildMessageInput(),

            // Messages List
            Expanded(
              child: _buildMessagesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'iPhone Companion',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
              ],
            ),
            if (_deviceInfo != null) ...[
              const SizedBox(height: 8),
              Text(
                'Device: ${_deviceInfo!.model}',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.secondaryLabel,
                    ),
              ),
              Text(
                'Device Type: ${_deviceInfo!.deviceType}',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.secondaryLabel,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _connectionState.isConnected
            ? CupertinoColors.systemGreen.withOpacity(0.1)
            : CupertinoColors.systemOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _connectionState.isConnected
              ? CupertinoColors.systemGreen
              : CupertinoColors.systemOrange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _connectionState.isConnected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_triangle,
            color: _connectionState.isConnected
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemOrange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _connectionState.isConnected
                  ? 'Connected to Apple Watch'
                  : 'Apple Watch not connected',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _messageController,
              placeholder: 'Send message to watch...',
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed:
                _messageController.text.trim().isNotEmpty ? _sendMessage : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                CupertinoIcons.arrow_up,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_2,
              size: 64,
              color: CupertinoColors.secondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to your Apple Watch',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: CupertinoColors.tertiaryLabel,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isFromSelf = message.sender?.contains('iOS') ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment:
                isFromSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isFromSelf) ...[
                const Icon(
                  CupertinoIcons.desktopcomputer,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isFromSelf
                        ? CupertinoColors.systemBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: isFromSelf
                                  ? CupertinoColors.white
                                  : CupertinoColors.label,
                            ),
                  ),
                ),
              ),
              if (isFromSelf) ...[
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.device_phone_portrait,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showConnectionInfo() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Connection Status'),
        message: Text(
          'Supported: ${_connectionState.isSupported}\n'
          'Paired: ${_connectionState.isPaired}\n'
          'Reachable: ${_connectionState.isReachable}\n'
          'Connected: ${_connectionState.isConnected}',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              widget.communicationService.testConnectivity();
            },
            child: const Text('Test Connection'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
