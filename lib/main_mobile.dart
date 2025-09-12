import 'package:flutter/material.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() => runApp(const PhoneApp());

class PhoneApp extends StatelessWidget {
  const PhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wear OS Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _wc = WatchConnectivity();
  String _lastMessage = 'No messages yet...';
  bool _isConnected = false;
  bool _isSending = false;
  bool _isSupported = false;
  bool _isPaired = false;
  bool _isReachable = false;
  String _connectionStatus = 'Checking...';
  final List<String> _connectedDevices = [];

  late AnimationController _pulseController;
  late AnimationController _connectionController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

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
      debugPrint('Watch connectivity supported: $_isSupported');

      if (_isSupported) {
        // Check if devices are paired
        _isPaired = await _wc.isPaired;
        debugPrint('Devices paired: $_isPaired');

        if (_isPaired) {
          // Check if watch is reachable
          _isReachable = await _wc.isReachable;
          debugPrint('Watch reachable: $_isReachable');

          // Get paired devices (if available)
          try {
            // This might not be available in all versions
            // _connectedDevices = await _wc.getConnectedDevices();
          } catch (e) {
            debugPrint('Could not get connected devices: $e');
          }
        }
      }

      // Listen for messages from watch
      _wc.messageStream.listen(
        (message) {
          debugPrint('Received message: $message');
          setState(() {
            _lastMessage =
                message['msg']?.toString() ?? 'Message received from watch';
            _isConnected = true;
            _isReachable = true;
            _connectionStatus = 'Connected & Active';
          });
          _connectionController.forward();
        },
        onError: (error) {
          debugPrint('Message stream error: $error');
          setState(() {
            _connectionStatus = 'Connection Error';
            _isConnected = false;
          });
        },
      );

      // Update UI with initial state
      setState(() {
        if (!_isSupported) {
          _connectionStatus = 'Watch Connectivity Not Supported';
        } else if (!_isReachable) {
          _connectionStatus = 'Watch Not Reachable';
        } else {
          _connectionStatus = 'Watch Connected';
          _isConnected = true;
        }
      });

      // Send a test ping to establish connection
      if (_isSupported && _isPaired) {
        _sendPingToWatch();
      }
    } catch (e) {
      debugPrint('Error initializing watch connectivity: $e');
      setState(() {
        _connectionStatus = 'Initialization Error';
        _isConnected = false;
      });
    }
  }

  Future<void> _sendPingToWatch() async {
    try {
      await _wc.sendMessage({
        'type': 'ping',
        'msg': 'Connection test from phone',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('Ping sent to watch');
    } catch (e) {
      debugPrint('Failed to send ping: $e');
    }
  }

  Future<void> _sendToWatch() async {
    if (!_isSupported || !_isConnected) {
      _showConnectionError();
      return;
    }

    setState(() => _isSending = true);

    try {
      final message = {
        'msg': 'Hello from Phone! 📱',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': 'greeting',
        'sender': 'phone',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      await _wc.sendMessage(message);
      debugPrint('Message sent: $message');

      // Wait a bit to see if we get a response
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Message sent to watch!',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to send: ${e.toString()}',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please pair a watch first in your phone settings',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _refreshConnection() async {
    setState(() {
      _connectionStatus = 'Refreshing...';
    });

    await _initializeWatchConnectivity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Section
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // Connection Status Card
                    _buildConnectionStatusCard(),

                    const SizedBox(height: 20),

                    // Message Display Card
                    _buildMessageCard(),

                    const SizedBox(height: 20),

                    // Debug Info Card
                    _buildDebugInfoCard(),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 32),

                    // Footer
                    _buildFooter(),

                    // Extra bottom padding for safety
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.watch,
            size: 36,
            color: Colors.white,
          ),
        ).animate().scale(delay: 200.ms, duration: 600.ms),
        const SizedBox(height: 12),
        Text(
          'Wear OS Companion',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 6),
        Text(
          'Connect with your smartwatch',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildConnectionStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  Color statusColor = _isConnected
                      ? Colors.green
                      : _isPaired
                          ? Colors.orange
                          : Colors.red;
                  return Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.5),
                          blurRadius: 6 * _pulseController.value,
                          spreadRadius: 1 * _pulseController.value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _connectionStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refreshConnection,
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (_connectedDevices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Devices:',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ..._connectedDevices.map(
                    (device) => Text(
                      '• $device',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().slideX(delay: 800.ms, begin: 1, duration: 600.ms);
  }

  Widget _buildMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.message,
                  color: Color(0xFF6366F1),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Latest Message',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _lastMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(delay: 1000.ms, begin: 1, duration: 600.ms);
  }

  Widget _buildDebugInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Information',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          _buildDebugRow('Supported', _isSupported.toString()),
          // _buildDebugRow('Paired', _isPaired.toString()),// Removed Paired status
          _buildDebugRow('Reachable', _isReachable.toString()),
          _buildDebugRow('Connected', _isConnected.toString()),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: value == 'true' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (_isSending || !_isSupported) ? null : _sendToWatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSending
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sending...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Send Message to Watch',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: _sendPingToWatch,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Send Test Ping',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ).animate().scale(delay: 1200.ms, duration: 600.ms);
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Made with ❤️ for Wear OS',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _isSupported
              ? (_isPaired
                  ? 'Watch is paired! Tap send to communicate'
                  : 'Please pair a watch in your phone settings')
              : 'Watch connectivity not supported on this device',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(delay: 1400.ms);
  }
}
