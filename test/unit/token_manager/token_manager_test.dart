import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:divine_foundation/Token Manager/token_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ManageTokens - User Tokens & Headers', () {
    test('setUserTokens saves token and cookie, and getTokenHeaders retrieves them', () async {
      await ManageTokens.setUserTokens(
        bToken: 'test_token_123',
        cookie: 'session_id=xyz',
      );

      final headers = await ManageTokens.getTokenHeaders();
      expect(headers, isNotNull);
      expect(headers!['Authorization'], 'Bearer test_token_123');
      expect(headers['Cookie'], 'session_id=xyz');
    });

    test('getTokenHeaders strips stray quotation marks from stored values', () async {
      SharedPreferences.setMockInitialValues({
        'bToken': '"quoted_token"',
        'cookie': '"quoted_cookie"',
      });

      final headers = await ManageTokens.getTokenHeaders();
      expect(headers!['Authorization'], 'Bearer quoted_token');
      expect(headers['Cookie'], 'quoted_cookie');
    });

    test('getTokenHeaders returns null when no token is stored', () async {
      final headers = await ManageTokens.getTokenHeaders();
      expect(headers, isNull);
    });

    test('getHttpHeadersWithToken includes standard Content-Type and Accept headers', () async {
      await ManageTokens.setUserTokens(
        bToken: 'jwt_abc',
        cookie: 'pref=dark',
      );

      final headers = await ManageTokens.getHttpHeadersWithToken();
      expect(headers[HttpHeaders.contentTypeHeader], 'application/json');
      expect(headers[HttpHeaders.acceptHeader], 'application/json');
      expect(headers['Authorization'], 'Bearer jwt_abc');
      expect(headers.containsKey('X-AUTH-CLIENT'), isFalse);
    });

    test('getHttpHeadersWithToken includes X-AUTH-CLIENT when isXAuthClient is true', () async {
      final headers = await ManageTokens.getHttpHeadersWithToken(isXAuthClient: true);
      expect(headers['X-AUTH-CLIENT'], isNotEmpty);
      expect(headers['X-AUTH-CLIENT'], 'cf896ad7-67ac-41fd-81f6-cffccc2a5bd3');
    });

    test('clearUserTokens removes stored authentication data', () async {
      SharedPreferences.setMockInitialValues({
        'bToken': 'my_token',
        'cookie': 'my_cookie',
        'isUserExist': true,
        'verified': true,
      });

      await ManageTokens.clearUserTokens();

      final headers = await ManageTokens.getTokenHeaders();
      expect(headers, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('bToken'), isFalse);
      expect(prefs.containsKey('cookie'), isFalse);
      expect(prefs.containsKey('isUserExist'), isFalse);
      expect(prefs.containsKey('verified'), isFalse);
    });
  });

  group('ManageTokens - Onboarding 48-Hour Expiration Logic', () {
    test('isOnboardingExpired initializes start time and returns false if not set', () async {
      final isExpired = await ManageTokens.isOnboardingExpired();
      expect(isExpired, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(ManageTokens.keyOnboardingStartTime), isTrue);
    });

    test('isOnboardingExpired returns false when within 48 hours', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final recentStart = now - (10 * 3600 * 1000); // 10 hours ago

      SharedPreferences.setMockInitialValues({
        ManageTokens.keyOnboardingStartTime: recentStart,
      });

      final isExpired = await ManageTokens.isOnboardingExpired();
      expect(isExpired, isFalse);
    });

    test('isOnboardingExpired returns true when 48 or more hours have passed', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final pastStart = now - (49 * 3600 * 1000); // 49 hours ago

      SharedPreferences.setMockInitialValues({
        ManageTokens.keyOnboardingStartTime: pastStart,
      });

      final isExpired = await ManageTokens.isOnboardingExpired();
      expect(isExpired, isTrue);
    });

    test('clearOnboardingStartTime removes start timestamp', () async {
      SharedPreferences.setMockInitialValues({
        ManageTokens.keyOnboardingStartTime: 12345678,
      });

      await ManageTokens.clearOnboardingStartTime();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(ManageTokens.keyOnboardingStartTime), isFalse);
    });

    test('clearOnboardingState clears all onboarding and auth state', () async {
      SharedPreferences.setMockInitialValues({
        'bToken': 'tok',
        'isProfileComplete': false,
        'role': 'Individual',
        ManageTokens.keyOnboardingStartTime: 12345678,
      });

      await ManageTokens.clearOnboardingState();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('bToken'), isFalse);
      expect(prefs.containsKey('isProfileComplete'), isFalse);
      expect(prefs.containsKey('role'), isFalse);
      expect(prefs.containsKey(ManageTokens.keyOnboardingStartTime), isFalse);
    });
  });
}
