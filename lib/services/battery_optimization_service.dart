import 'dart:io';
import 'package:flutter/services.dart';

/// Service for checking and managing battery optimization settings on Android.
///
/// Battery optimization can interfere with background timer accuracy by
/// restricting app background execution. This service helps detect and
/// guide users to disable optimization for reliable timer operation.
class BatteryOptimizationService {
  static const MethodChannel _channel = MethodChannel(
    'com.timetracker/timer_service',
  );

  /// Check if battery optimization is disabled for the app.
  ///
  /// Returns:
  /// - `true` if battery optimization is disabled/ignored (good for timers)
  /// - `false` if battery optimization is enabled (may affect timers)
  ///
  /// On iOS or unsupported Android versions, always returns `true` since
  /// battery optimization is not applicable or not available.
  static Future<bool> checkBatteryOptimizationStatus() async {
    // Battery optimization only applies to Android
    if (!Platform.isAndroid) {
      return true; // Not applicable on iOS
    }

    try {
      final result = await _channel.invokeMethod(
        'isBatteryOptimizationIgnored',
      );
      return result as bool;
    } on PlatformException catch (e) {
      print('Failed to check battery optimization status: ${e.message}');
      // Default to true to avoid blocking users on error
      return true;
    }
  }

  /// Open Android's battery optimization settings for this app.
  ///
  /// This allows the user to disable battery optimization, which improves
  /// background timer reliability. The system settings dialog will be shown
  /// where the user can toggle the optimization setting.
  ///
  /// Only works on Android API 23+. Does nothing on iOS or older Android versions.
  static Future<void> requestBatteryOptimizationExemption() async {
    // Battery optimization only applies to Android
    if (!Platform.isAndroid) {
      return; // Not applicable on iOS
    }

    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
    } on PlatformException catch (e) {
      print('Failed to open battery optimization settings: ${e.message}');
      rethrow;
    }
  }

  /// Check if the current platform supports battery optimization management.
  ///
  /// Returns `true` on Android, `false` on other platforms.
  static bool isPlatformSupported() {
    return Platform.isAndroid;
  }
}
