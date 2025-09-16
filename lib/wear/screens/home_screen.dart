import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/services/communication_service.dart';
import '../../shared/models/device_info.dart' as device_models;
import '../../shared/utils/app_theme.dart';
import '../../shared/utils/app_utils.dart';

class WearHomeScreen extends StatefulWidget {
  const WearHomeScreen({super.key});

  @override
  State<WearHomeScreen> createState() => _WearHomeScreenState();
}

class _WearHomeScreenState extends State<WearHomeScreen>
    with TickerProviderStateMixin {
  final CommunicationService _communicationService = CommunicationService();

  String _lastMessage = 'Waiting for phone...';
  DateTime? _lastMessageTime;
  bool _isSending = false;

  device_models.ConnectionState _connectionState =
      device_models.ConnectionState(
    isSupported: false,
    isPaired: false,
    isReachable: false,
    isConnected: false,
    status: 'Initializing...',
    lastUpdate: DateTime.now(),
  );

  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  void _setupListeners() {
    // Listen to connection changes
    _communicationService.connectionStream.listen((connectionState) {
      if (mounted) {
        setState(() {
          _connectionState = connectionState;
        });
      }
    });

    // Listen to incoming messages
    _communicationService.messageStream.listen((message) {
      if (mounted) {
        setState(() {
          _lastMessage = message.content;
          _lastMessageTime = message.timestamp;
        });
      }
    });
  }

  Future<void> _sendQuickResponse(String response) async {
    setState(() {
      _isSending = true;
    });

    final success = await _communicationService.sendTextMessage(response);

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }

    if (success) {
      _rippleController.forward(from: 0);
    }
  }

  Future<void> _sendPing() async {
    await _communicationService.sendPing();
    _rippleController.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildWatchInterface(),
      ),
    );
  }

  Widget _buildWatchInterface() {
    return Stack(
      children: [
        _buildBackground(),
        _buildMainContent(),
      ],
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _rotationController.value * 2 * 3.14159,
              colors: const [
                Color.fromARGB(255, 0, 0, 0),
                Color.fromARGB(200, 156, 95, 235),
                Color.fromARGB(255, 160, 45, 175),
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactHeader(),
          _buildCenterContent(),
          _buildCompactActions(),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppTheme.getConnectionColor(_connectionState.isConnected)
                          .withOpacity(0.3 + 0.7 * _pulseController.value),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _connectionState.isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.5, end: 0);
  }

  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMessageDisplay(),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildMessageDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.secondaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.message,
            color: Colors.white.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            _lastMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildCompactActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactActionButton(
            '👋', () => _sendQuickResponse('Hello from watch!')),
        _buildCompactActionButton('👍', () => _sendQuickResponse('OK')),
        _buildCompactActionButton('📱', _sendPing),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildCompactActionButton(String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: _connectionState.isConnected && !_isSending ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: _connectionState.isConnected && !_isSending
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.6),
                    AppTheme.secondaryColor.withOpacity(0.6),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
