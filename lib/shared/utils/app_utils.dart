import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Utility functions for the app
class AppUtils {
  /// Format timestamp to readable string
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Format timestamp to time string
  static String formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Generate a random ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Safely parse JSON string
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AppUtils: Error parsing JSON: $e');
      return null;
    }
  }

  /// Safely convert object to JSON string
  static String? toJsonString(dynamic object) {
    try {
      return json.encode(object);
    } catch (e) {
      debugPrint('AppUtils: Error encoding to JSON: $e');
      return null;
    }
  }

  /// Truncate text to specified length
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Check if a string is a valid JSON
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Debounce function calls
  static void debounce(VoidCallback callback, Duration delay) {
    // Note: This is a simple implementation. For production, consider using
    // a more robust debouncing mechanism with Timer.
    Future.delayed(delay, callback);
  }
}