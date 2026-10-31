import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Utilities/helper.dart';

void main() {
  group('Helper Functions - cleanHtml', () {
    test('removes basic HTML tags and returns trimmed text', () {
      const html = '<p>Hello <b>World</b></p>';
      expect(cleanHtml(html), 'Hello World');
    });

    test('unescapes HTML entities properly', () {
      const html = '&lt;div&gt;Tom &amp; Jerry &quot;Show&quot;&#39;s&lt;/div&gt;';
      expect(cleanHtml(html), '<div>Tom & Jerry "Show"\'s</div>');
    });

    test('collapses multiple whitespace characters into single space', () {
      const html = '<p>Line 1</p>   \n\n  <p>Line   2</p>';
      expect(cleanHtml(html), 'Line 1 Line 2');
    });

    test('returns empty string for empty input', () {
      expect(cleanHtml(''), '');
    });
  });

  group('Helper Functions - formatPrice', () {
    test('formats numbers below 1000 correctly as integers or decimals', () {
      expect(formatPrice(0), '0');
      expect(formatPrice(100), '100');
      expect(formatPrice(999), '999');
      expect(formatPrice(50.5), '50.5');
      expect(formatPrice(50.0), '50');
    });

    test('formats thousands with K suffix', () {
      expect(formatPrice(1000), '1K');
      expect(formatPrice(1500), '1.5K');
      expect(formatPrice(25000), '25K');
      expect(formatPrice(999000), '999K');
    });

    test('formats millions with M suffix', () {
      expect(formatPrice(1000000), '1M');
      expect(formatPrice(2500000), '2.5M');
      expect(formatPrice(10000000), '10M');
    });

    test('formats billions with B suffix', () {
      expect(formatPrice(1000000000), '1B');
      expect(formatPrice(3500000000), '3.5B');
    });
  });

  group('Helper Functions - Time & Date Logic', () {
    test('isBefore correctly compares TimeOfDay instances', () {
      const t1 = TimeOfDay(hour: 9, minute: 30);
      const t2 = TimeOfDay(hour: 10, minute: 15);
      const t3 = TimeOfDay(hour: 9, minute: 45);

      expect(isBefore(t1, t2), isTrue);
      expect(isBefore(t2, t1), isFalse);
      expect(isBefore(t1, t3), isTrue);
      expect(isBefore(t1, t1), isFalse);
    });

    test('isAfterOrEqual correctly checks if time is equal or later', () {
      const t1 = TimeOfDay(hour: 14, minute: 0);
      const t2 = TimeOfDay(hour: 14, minute: 0);
      const t3 = TimeOfDay(hour: 13, minute: 59);
      const t4 = TimeOfDay(hour: 15, minute: 0);

      expect(isAfterOrEqual(t1, t2), isTrue);
      expect(isAfterOrEqual(t1, t3), isTrue);
      expect(isAfterOrEqual(t1, t4), isFalse);
    });

    test('isSameDate checks if two dates have identical year, month, and day', () {
      final d1 = DateTime(2026, 10, 10, 8, 30);
      final d2 = DateTime(2026, 10, 10, 22, 15);
      final d3 = DateTime(2026, 10, 11, 8, 30);
      final d4 = DateTime(2025, 10, 10, 8, 30);

      expect(isSameDate(d1, d2), isTrue);
      expect(isSameDate(d1, d3), isFalse);
      expect(isSameDate(d1, d4), isFalse);
    });

    test('formatTime formats TimeOfDay with AM/PM and handles null', () {
      expect(formatTime(null), '--:--');
      expect(formatTime(const TimeOfDay(hour: 0, minute: 0)), '12:00 AM');
      expect(formatTime(const TimeOfDay(hour: 12, minute: 0)), '12:00 PM');
      expect(formatTime(const TimeOfDay(hour: 9, minute: 5)), '9:05 AM');
      expect(formatTime(const TimeOfDay(hour: 17, minute: 45)), '5:45 PM');
    });
  });

  group('Helper Functions - maskName', () {
    test('masks single word names', () {
      expect(maskName('A'), 'A');
      expect(maskName('Jo'), 'Jo');
      expect(maskName('Ram'), 'R*m');
      expect(maskName('Rahul'), 'R***l');
    });

    test('masks multi-word names for first and last word', () {
      expect(maskName('Rahul Sharma'), 'R***l S****a');
      expect(maskName('A B'), 'A B');
      expect(maskName('Om Prakash'), 'Om P*****h');
    });

    test('handles whitespace and empty strings gracefully', () {
      expect(maskName(''), '');
      expect(maskName('   '), '   ');
    });
  });

  group('Helper Functions - formatErrorMessage', () {
    test('returns connection message for null error', () {
      expect(formatErrorMessage(null), 'Please check your internet connection');
    });

    test('returns generic message for empty error', () {
      expect(formatErrorMessage(''), 'Something went wrong. Please try again.');
      expect(formatErrorMessage('   '), 'Something went wrong. Please try again.');
    });

    test('identifies network and socket exceptions', () {
      expect(formatErrorMessage('SocketException: OS Error: Failed host lookup'),
          'Please check your internet connection');
      expect(formatErrorMessage('ClientException: Connection closed before full response'),
          'Please check your internet connection');
      expect(formatErrorMessage('HandshakeException: Connection timed out'),
          'Please check your internet connection');
      expect(formatErrorMessage('no internet available'),
          'Please check your internet connection');
    });

    test('strips Exception and Error prefixes cleanly', () {
      expect(formatErrorMessage('Error: Exception: User already exists'), 'User already exists');
      expect(formatErrorMessage('Exception: Invalid OTP entered'), 'Invalid OTP entered');
      expect(formatErrorMessage('Error: Mobile number not registered'), 'Mobile number not registered');
      expect(formatErrorMessage('Campaign goal reached'), 'Campaign goal reached');
    });
  });
}
