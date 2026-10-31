import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Model/wallet_model.dart';
import 'package:divine_foundation/Model/coupon_model.dart';

void main() {
  group('WalletModel & WalletData Parsing', () {
    test('parses balance fields with diverse fallback keys and numeric types', () {
      final json1 = {
        'status': true,
        'data': {
          'walletBalance': 1250.75,
          'cashbackBalance': 150.0,
          'totalCoins': 500,
          'coinsValueInRupees': 50.0,
          'transactions': [
            {
              '_id': 'tx_1',
              'amount': 250,
              'type': 'credit',
              'status': 'completed',
              'item': 'Wallet Topup',
              'date': '2026-10-10T12:00:00Z',
            }
          ]
        }
      };

      final walletModel = WalletModel.fromJson(json1);
      expect(walletModel.status, isTrue);
      expect(walletModel.data?.walletBalance, 1250.75);
      expect(walletModel.data?.cashbackBalance, 150.0);
      expect(walletModel.data?.totalCoins, 500);
      expect(walletModel.data?.coinsValueInRupees, 50.0);
      expect(walletModel.data?.transactions?.length, 1);
      expect(walletModel.data?.transactions?.first.type, 'credit');
      expect(walletModel.data?.transactions?.first.status, 'completed');
    });

    test('falls back to string or alternative balance keys gracefully', () {
      final jsonAlt = {
        'wallet_balance': '500',
        'cashback_balance': '25.5',
        'coins': '100',
      };

      final walletData = WalletData.fromJson(jsonAlt);
      expect(walletData.walletBalance, 500.0);
      expect(walletData.cashbackBalance, 25.5);
      expect(walletData.totalCoins, 100);
    });

    test('toJson produces expected map output', () {
      final walletModel = WalletModel(
        status: true,
        data: WalletData(
          walletBalance: 100.0,
          cashbackBalance: 10.0,
          totalCoins: 200,
          coinsValueInRupees: 20.0,
        ),
      );

      final map = walletModel.toJson();
      expect(map['status'], isTrue);
      expect(map['data']['walletBalance'], 100.0);
      expect(map['data']['cashbackBalance'], 10.0);
      expect(map['data']['totalCoins'], 200);
    });

    test('RechargeTier parses correctly', () {
      final tier = RechargeTier(
        tierId: 'T1',
        amount: 500,
        cashback: 50,
        bonusCoins: 500,
        badgeText: 'Popular',
      );

      expect(tier.amount, 500);
      expect(tier.cashback, 50);
      expect(tier.bonusCoins, 500);
      expect(tier.badgeText, 'Popular');
    });
  });

  group('CouponModel & Coupon Parsing', () {
    test('parses coupon lists and calculates discount correctly', () {
      final json = {
        'status': true,
        'data': [
          {
            '_id': 'c_1',
            'code': 'DIVINE50',
            'description': 'Flat 50 off',
            'discountType': 'flat',
            'value': 50,
            'minDonation': 200,
            'isActive': true,
          },
          {
            '_id': 'c_2',
            'code': 'FESTIVE10',
            'description': '10% off',
            'discountType': 'percentage',
            'value': 10,
            'minDonation': 500,
            'isActive': true,
          }
        ]
      };

      final couponModel = CouponModel.fromJson(json);
      expect(couponModel.status, isTrue);
      expect(couponModel.data?.length, 2);

      final c1 = couponModel.data![0];
      expect(c1.code, 'DIVINE50');
      expect(c1.value, 50.0);
      expect(c1.minDonation, 200.0);
      expect(c1.isActive, isTrue);

      final c2 = couponModel.data![1];
      expect(c2.discountType, 'percentage');
      expect(c2.value, 10.0);
    });

    test('toJson serializes coupon data properly', () {
      final coupon = Coupon(
        sId: '123',
        code: 'SAVE100',
        value: 100.0,
        minDonation: 1000.0,
      );

      final map = coupon.toJson();
      expect(map['_id'], '123');
      expect(map['code'], 'SAVE100');
      expect(map['value'], 100.0);
      expect(map['minDonation'], 1000.0);
    });
  });
}
