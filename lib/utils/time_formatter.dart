class TimeFormatter {
  /// Format seconds as HH:MM:SS
  /// Example: 3661 seconds -> "01:01:01"
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Format elapsed time for display
  /// Short durations (< 1 hour): "MM:SS"
  /// Long durations (≥ 1 hour): "HH:MM:SS"
  static String formatElapsedTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  /// Format seconds as human-readable text
  /// Example: "2 hours 15 minutes"
  static String formatHumanReadable(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }
  }
}
