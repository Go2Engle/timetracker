import 'package:flutter_test/flutter_test.dart';
import 'package:timetracker/utils/time_formatter.dart';

void main() {
  group('TimeFormatter Tests', () {
    test('formatDuration formats seconds as HH:MM:SS', () {
      expect(TimeFormatter.formatDuration(0), '00:00:00');
      expect(TimeFormatter.formatDuration(59), '00:00:59');
      expect(TimeFormatter.formatDuration(60), '00:01:00');
      expect(TimeFormatter.formatDuration(3600), '01:00:00');
      expect(TimeFormatter.formatDuration(3661), '01:01:01');
      expect(TimeFormatter.formatDuration(7325), '02:02:05');
    });

    test('formatElapsedTime shows MM:SS for < 1 hour', () {
      expect(TimeFormatter.formatElapsedTime(0), '00:00');
      expect(TimeFormatter.formatElapsedTime(59), '00:59');
      expect(TimeFormatter.formatElapsedTime(60), '01:00');
      expect(TimeFormatter.formatElapsedTime(3599), '59:59');
    });

    test('formatElapsedTime shows HH:MM:SS for ≥ 1 hour', () {
      expect(TimeFormatter.formatElapsedTime(3600), '01:00:00');
      expect(TimeFormatter.formatElapsedTime(3661), '01:01:01');
      expect(TimeFormatter.formatElapsedTime(7200), '02:00:00');
    });

    test('formatHumanReadable formats correctly', () {
      expect(TimeFormatter.formatHumanReadable(30), '30 seconds');
      expect(TimeFormatter.formatHumanReadable(1), '1 second');
      expect(TimeFormatter.formatHumanReadable(60), '1 minute');
      expect(TimeFormatter.formatHumanReadable(120), '2 minutes');
      expect(TimeFormatter.formatHumanReadable(3600), '1 hour');
      expect(TimeFormatter.formatHumanReadable(7200), '2 hours');
      expect(TimeFormatter.formatHumanReadable(3660), '1 hour 1 minute');
      expect(TimeFormatter.formatHumanReadable(7320), '2 hours 2 minutes');
    });
  });
}
