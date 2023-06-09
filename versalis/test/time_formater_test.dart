import 'package:flutter_test/flutter_test.dart';
import 'package:versalis/View/audioplayerScreen.dart';

void main() {
  group('formatTime', () {
    test('should format a duration to a string in hh:mm:ss format', () {
      final duration = Duration(hours: 1, minutes: 23, seconds: 45);
      expect(formatTime(duration), equals('01:23:45'));
    });

    test('should format a duration to a string in mm:ss format when hours are 0', () {
      final duration = Duration(minutes: 23, seconds: 45);
      expect(formatTime(duration), equals('23:45'));
    });

    test('should format a duration to a string in ss format when minutes and hours are 0', () {
      final duration = Duration(seconds: 45);
      expect(formatTime(duration), equals('00:45'));
    });
  });
}
