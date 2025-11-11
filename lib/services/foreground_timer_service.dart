import 'dart:convert';
import 'package:flutter/services.dart';

class ForegroundTimerService {
  static const MethodChannel _channel = MethodChannel('com.timetracker/timer_service');

  /// Start the foreground service with initial timer data
  static Future<void> startForegroundService(List<TimerData> timers) async {
    final timersJson = jsonEncode(timers.map((t) => t.toJson()).toList());
    
    try {
      await _channel.invokeMethod('startForegroundService', {
        'timersJson': timersJson,
      });
    } on PlatformException catch (e) {
      print('Failed to start foreground service: ${e.message}');
      rethrow;
    }
  }

  /// Update timer data in the running foreground service
  static Future<void> updateTimers(List<TimerData> timers) async {
    final timersJson = jsonEncode(timers.map((t) => t.toJson()).toList());
    
    try {
      await _channel.invokeMethod('updateTimers', {
        'timersJson': timersJson,
      });
    } on PlatformException catch (e) {
      print('Failed to update timers: ${e.message}');
      rethrow;
    }
  }

  /// Stop the foreground service
  static Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (e) {
      print('Failed to stop foreground service: ${e.message}');
      rethrow;
    }
  }

  /// Check if the foreground service is running
  static Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result as bool;
    } on PlatformException catch (e) {
      print('Failed to check service status: ${e.message}');
      return false;
    }
  }

  /// Get timer states from the foreground service
  /// Returns a map with 'timerStates' (JSON string) and 'lastUpdate' (timestamp)
  static Future<Map<String, dynamic>?> getTimerStates() async {
    try {
      final result = await _channel.invokeMethod('getTimerStates');
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      print('Failed to get timer states: ${e.message}');
      return null;
    }
  }
}

/// Data class for timer information to pass to native service
class TimerData {
  final int taskId;
  final String taskName;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final int sessionStartTime; // Unix timestamp in milliseconds

  TimerData({
    required this.taskId,
    required this.taskName,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
    required this.sessionStartTime,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskName': taskName,
        'elapsedSeconds': elapsedSeconds,
        'isRunning': isRunning,
        'isPaused': isPaused,
        'sessionStartTime': sessionStartTime,
      };

  factory TimerData.fromJson(Map<String, dynamic> json) => TimerData(
        taskId: json['taskId'] as int,
        taskName: json['taskName'] as String,
        elapsedSeconds: json['elapsedSeconds'] as int,
        isRunning: json['isRunning'] as bool,
        isPaused: json['isPaused'] as bool,
        sessionStartTime: json['sessionStartTime'] as int,
      );
}
