import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Repo/common_repo.dart';

void main() {
  group('ApiLogger - sanitizeMap', () {
    test('returns empty map when input is null', () {
      final result = ApiLogger.sanitizeMap(null);
      expect(result, isEmpty);
    });

    test('leaves non-sensitive fields unchanged', () {
      final input = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'amount': 500,
        'isActive': true,
      };
      final result = ApiLogger.sanitizeMap(input);
      expect(result['name'], 'John Doe');
      expect(result['email'], 'john@example.com');
      expect(result['amount'], 500);
      expect(result['isActive'], isTrue);
    });

    test('replaces sensitive keys with [PROTECTED] regardless of case', () {
      final input = {
        'password': 'mySecretPassword123',
        'oldPassword': 'oldPassword123',
        'newPassword': 'newPassword123',
        'PIN': '1234',
        'Otp': '998877',
        'token': 'jwt.token.here',
        'accessToken': 'access_123',
        'refreshToken': 'refresh_456',
        'secret': 'client_secret_xyz',
      };
      final result = ApiLogger.sanitizeMap(input);

      expect(result['password'], '[PROTECTED]');
      expect(result['oldPassword'], '[PROTECTED]');
      expect(result['newPassword'], '[PROTECTED]');
      expect(result['PIN'], '[PROTECTED]');
      expect(result['Otp'], '[PROTECTED]');
      expect(result['token'], '[PROTECTED]');
      expect(result['accessToken'], '[PROTECTED]');
      expect(result['refreshToken'], '[PROTECTED]');
      expect(result['secret'], '[PROTECTED]');
    });

    test('recursively sanitizes nested maps', () {
      final input = {
        'user': {
          'name': 'Alice',
          'credentials': {
            'password': 'nestedPassword',
            'token': 'nestedToken',
          },
        },
        'status': 'active',
      };
      final result = ApiLogger.sanitizeMap(input);

      expect(result['status'], 'active');
      expect(result['user']['name'], 'Alice');
      expect(result['user']['credentials']['password'], '[PROTECTED]');
      expect(result['user']['credentials']['token'], '[PROTECTED]');
    });
  });

  group('ApiLogger - sanitizeHeaders', () {
    test('returns empty map when input is null', () {
      final result = ApiLogger.sanitizeHeaders(null);
      expect(result, isEmpty);
    });

    test('preserves regular non-sensitive headers', () {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp/1.0',
      };
      final result = ApiLogger.sanitizeHeaders(headers);
      expect(result['Content-Type'], 'application/json');
      expect(result['Accept'], 'application/json');
      expect(result['User-Agent'], 'FlutterApp/1.0');
    });

    test('masks Authorization header with Bearer prefix', () {
      final headers = {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      };
      final result = ApiLogger.sanitizeHeaders(headers);
      expect(result['Authorization'], 'Bearer [PROTECTED]');
    });

    test('masks Authorization and token headers without Bearer prefix', () {
      final headers = {
        'Authorization': 'Basic dXNlcjpwYXNz',
        'x-access-token': 'token_abc_123',
      };
      final result = ApiLogger.sanitizeHeaders(headers);
      expect(result['Authorization'], '[PROTECTED]');
      expect(result['x-access-token'], '[PROTECTED]');
    });
  });

  group('ApiLogger - Logging invocations', () {
    test('does not throw when calling logging methods', () {
      expect(
        () => ApiLogger.logRequest(
          method: 'GET',
          url: 'https://example.com/api',
          headers: {'Authorization': 'Bearer 123'},
          body: {'password': 'abc'},
        ),
        returnsNormally,
      );

      expect(
        () => ApiLogger.logDeduplicated(method: 'POST', url: 'https://example.com/api'),
        returnsNormally,
      );

      expect(
        () => ApiLogger.logResponse(
          method: 'POST',
          url: 'https://example.com/api',
          statusCode: 200,
          responseBody: '{"status":true}',
        ),
        returnsNormally,
      );

      expect(
        () => ApiLogger.logError(
          method: 'GET',
          url: 'https://example.com/api',
          error: 'Connection timed out',
        ),
        returnsNormally,
      );
    });
  });
}
