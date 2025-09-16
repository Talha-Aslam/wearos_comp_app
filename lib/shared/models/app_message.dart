/// Message model for communication between phone and watch
class AppMessage {
  final String id;
  final String type;
  final String content;
  final DateTime timestamp;
  final String? sender;
  final Map<String, dynamic>? data;

  const AppMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.sender,
    this.data,
  });

  /// Creates AppMessage from JSON
  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sender: json['sender'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Converts AppMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender,
      'data': data,
    };
  }

  /// Creates a copy with updated fields
  AppMessage copyWith({
    String? id,
    String? type,
    String? content,
    DateTime? timestamp,
    String? sender,
    Map<String, dynamic>? data,
  }) {
    return AppMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'AppMessage(id: $id, type: $type, content: $content, timestamp: $timestamp, sender: $sender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppMessage &&
        other.id == id &&
        other.type == type &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.sender == sender;
  }

  @override
  int get hashCode {
    return Object.hash(id, type, content, timestamp, sender);
  }
}

/// Message types for different communication scenarios
class MessageTypes {
  static const String ping = 'ping';
  static const String pong = 'pong';
  static const String status = 'status';
  static const String command = 'command';
  static const String response = 'response';
  static const String notification = 'notification';
  static const String heartbeat = 'heartbeat';
  static const String data = 'data';
  static const String presence = 'presence';
}