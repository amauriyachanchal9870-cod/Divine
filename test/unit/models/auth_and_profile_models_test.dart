import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Model/login_model.dart';
import 'package:divine_foundation/Model/verify_otp_model.dart';
import 'package:divine_foundation/Model/master_settings_model.dart';

void main() {
  group('LoginModel Parsing & Serialization', () {
    test('fromJson sets all fields correctly', () {
      final json = {
        'status': true,
        'message': 'OTP sent successfully',
        'isUserExist': true,
        'phone': '9876543210',
        'otp': '123456',
      };

      final loginModel = LoginModel.fromJson(json);
      expect(loginModel.status, isTrue);
      expect(loginModel.message, 'OTP sent successfully');
      expect(loginModel.isUserExist, isTrue);
      expect(loginModel.phone, '9876543210');
      expect(loginModel.otp, '123456');
    });

    test('toJson serializes correctly', () {
      final model = LoginModel(
        status: true,
        message: 'Success',
        isUserExist: false,
        phone: '9999999999',
        otp: '9999',
      );

      final map = model.toJson();
      expect(map['status'], isTrue);
      expect(map['isUserExist'], isFalse);
      expect(map['phone'], '9999999999');
      expect(map['otp'], '9999');
    });
  });

  group('VerifyOtpModel Parsing & Serialization', () {
    test('fromJson parses token, verified flag, and nested user data', () {
      final json = {
        'status': true,
        'message': 'Login successful',
        'token': 'jwt_secret_token_123',
        'isProfileComplete': true,
        'verified': true,
        'data': {
          '_id': 'usr_1',
          'phone': '9876543210',
          'name': 'Rahul Verma',
          'email': 'rahul@example.com',
          'gender': 'Male',
          'role': 'Individual',
        }
      };

      final verifyModel = VerifyOtpModel.fromJson(json);
      expect(verifyModel.status, isTrue);
      expect(verifyModel.token, 'jwt_secret_token_123');
      expect(verifyModel.isProfileComplete, isTrue);
      expect(verifyModel.isVerified, isTrue);
      expect(verifyModel.data, isNotNull);
      expect(verifyModel.data?.name, 'Rahul Verma');
      expect(verifyModel.data?.role, 'Individual');
    });

    test('toJson produces expected dictionary with user data', () {
      final model = VerifyOtpModel(
        status: true,
        token: 'tok_abc',
        isProfileComplete: false,
        isVerified: true,
        data: UserData(
          id: '123',
          name: 'Priya',
          phone: '9876543210',
        ),
      );

      final json = model.toJson();
      expect(json['token'], 'tok_abc');
      expect(json['isProfileComplete'], isFalse);
      expect(json['verified'], isTrue);
      expect(json['data']['name'], 'Priya');
    });
  });

  group('MasterSettingsModel Parsing', () {
    test('fromJson parses settings arrays and IDs correctly', () {
      final json = {
        'status': true,
        'data': {
          '_id': 'settings_1',
          'csrFocusAreas': ['Healthcare', 'Education'],
          'fundingPreferences': ['Monthly', 'One-Time'],
          'nonProfitTypes': ['Trust', 'Society', 'Section 8'],
          'corporateCompanyTypes': ['Private', 'Public'],
          'createdAt': '2026-01-01',
        }
      };

      final settingsModel = MasterSettingsModel.fromJson(json);
      expect(settingsModel.status, isTrue);
      expect(settingsModel.data?.sId, 'settings_1');
      expect(settingsModel.data?.csrFocusAreas, contains('Healthcare'));
      expect(settingsModel.data?.fundingPreferences, contains('Monthly'));
      expect(settingsModel.data?.nonProfitTypes?.length, 3);
      expect(settingsModel.data?.corporateCompanyTypes, contains('Private'));

      final serialized = settingsModel.toJson();
      expect(serialized['status'], isTrue);
      expect(serialized['data']['_id'], 'settings_1');
    });
  });
}
