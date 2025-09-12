import 'package:flutter/material.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() => runApp(const WearOSApp());

class WearOSApp extends StatelessWidget {
  const WearOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wear OS Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const WatchHomeScreen(),
    );
  }
}

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen>
    with TickerProviderStateMixin {
  final _wc = WatchConnectivity();
  String _lastMessage = 'Waiting for phone...';
  bool _isConnected = false;
  bool _isSending = false;
  bool _isSupported = false;
  bool _isPaired = false;
  bool _isReachable = false;
  int _messageCount = 0;
  DateTime? _lastMessageTime;

  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late AnimationController _connectionController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeWatchConnectivity();
  }

  Future<void> _initializeWatchConnectivity() async {
    try {
      // Check if watch connectivity is supported
      _isSupported = await _wc.isSupported;
      print('Watch connectivity supported: $_isSupported');

      if (_isSupported) {
        // Check if devices are paired
        _isPaired = await _wc.isPaired;
        print('Devices paired: $_isPaired');

        if (_isPaired) {
          // Check if phone is reachable
          _isReachable = await _wc.isReachable;
          print('Phone reachable: $_isReachable');
        }
      }

      // Listen for messages from phone
      _wc.messageStream.listen(
        (message) {
          print('Received message from phone: $message');
          setState(() {
            _lastMessage =
                message['msg']?.toString() ?? 'Message received from phone';
            _isConnected = true;
            _isReachable = true;
            _messageCount++;
            _lastMessageTime = DateTime.now();
          });

          // Trigger ripple effect
          _rippleController.forward().then((_) => _rippleController.reset());
          _connectionController.forward();

          // Auto-respond to ping messages
          if (message['type'] == 'ping') {
            _sendAutoResponse();
          }
        },
        onError: (error) {
          print('Message stream error: $error');
          setState(() {
            _isConnected = false;
          });
        },
      );

      // Update UI with initial state
      setState(() {
        if (!_isSupported) {
        } else if (!_isPaired) {
        } else if (!_isReachable) {
        } else {
          _isConnected = true;
        }
      });

      // Send initial ping to establish connection
      if (_isSupported && _isPaired) {
        _sendInitialPing();
      }
    } catch (e) {
      print('Error initializing watch connectivity: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _sendInitialPing() async {
    try {
      await _wc.sendMessage({
        'type': 'watch_ping',
        'msg': 'Watch app started',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': 'watch',
      });
      print('Initial ping sent to phone');
    } catch (e) {
      print('Failed to send initial ping: $e');
    }
  }

  Future<void> _sendAutoResponse() async {
    try {
      await _wc.sendMessage({
        'type': 'ping_response',
        'msg': 'Pong from watch! 👋',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': 'watch',
      });
      print('Auto-response sent to phone');
    } catch (e) {
      print('Failed to send auto-response: $e');
    }
  }

  Future<void> _sendToPhone() async {
    if (!_isSupported || !_isPaired) {
      _showConnectionError();
      return;
    }

    setState(() => _isSending = true);

    try {
      final message = {
        'msg': 'Hello from Watch! ⌚✨',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': 'watch_greeting',
        'sender': 'watch',
        'battery': '85%', // Mock battery level
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await _wc.sendMessage(message);
      print('Message sent to phone: $message');

      // Wait a bit for potential response
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('Sent to Phone!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('Failed: ${e.toString()}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      )),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showConnectionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Please pair with phone first',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatLastMessageTime() {
    if (_lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(_lastMessageTime!);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = screenSize.width == screenSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF1A1B3A),
              Color(0xFF0F0F23),
              Colors.black,
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isRound ? 4.0 : 6.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add some top padding to center content vertically
                  SizedBox(height: screenSize.height * 0.02),

                  // Rotating border animation
                  _buildAnimatedBorder(),

                  SizedBox(height: screenSize.height * 0.02),

                  // Connection status
                  _buildConnectionStatus(),

                  SizedBox(height: screenSize.height * 0.03),

                  // Message display
                  _buildMessageDisplay(),

                  SizedBox(height: screenSize.height * 0.02),

                  // Debug info (compact for watch)
                  _buildDebugInfo(),

                  SizedBox(height: screenSize.height * 0.03),

                  // Send button
                  _buildSendButton(),

                  // Add some bottom padding
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBorder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rotating ring
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Colors.transparent,
                  ),
                  gradient: const SweepGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Inner pulsing circle
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 35 + (_pulseController.value * 5),
              height: 35 + (_pulseController.value * 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.smartphone,
                color: Colors.white,
                size: 16,
              ),
            );
          },
        ),

        // Ripple effect
        AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            if (_rippleController.status == AnimationStatus.forward) {
              return Container(
                width: 35 + (_rippleController.value * 20),
                height: 35 + (_rippleController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Colors.green.withOpacity(1 - _rippleController.value),
                    width: 2,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    ).animate().scale(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (_isConnected ? Colors.green : Colors.orange).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected ? Colors.green : Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color: (_isConnected ? Colors.green : Colors.orange)
                          .withOpacity(_pulseController.value * 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _isConnected ? 'Connected' : 'Searching...',
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: _isConnected ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildMessageDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                color: Colors.white.withOpacity(0.7),
                size: 10,
              ),
              const SizedBox(width: 4),
              Text(
                'Messages: $_messageCount',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              if (_lastMessageTime != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatLastMessageTime(),
                  style: GoogleFonts.poppins(
                    fontSize: 7,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _lastMessage,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().slideY(delay: 600.ms, begin: 0.5, duration: 600.ms);
  }

  Widget _buildDebugInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusDot('Supported', _isSupported),
              _buildStatusDot('Paired', _isPaired),
              _buildStatusDot('Reachable', _isReachable),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildStatusDot(String label, bool status) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: (_isSending || !_isSupported) ? null : _sendToPhone,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isSending
              ? LinearGradient(
                  colors: [
                    Colors.grey.shade600,
                    Colors.grey.shade700,
                  ],
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: _isSending
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                Icons.send,
                color: Colors.white,
                size: 16,
              ),
      ),
    ).animate().scale(delay: 1000.ms, duration: 600.ms);
  }
}
