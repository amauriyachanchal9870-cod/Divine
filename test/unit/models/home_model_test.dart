import 'package:flutter_test/flutter_test.dart';
import 'package:divine_foundation/Model/home_model.dart';

void main() {
  group('HomeCampaign Model Calculations', () {
    test('parses goal and raised amounts correctly from various string representations', () {
      final campaign1 = HomeCampaign(
        sId: '1',
        title: 'Education for All',
        goal: '50000',
        raised: '25000',
        donorsCount: 150,
      );

      expect(campaign1.goalAmount, 50000.0);
      expect(campaign1.raisedAmount, 25000.0);
      expect(campaign1.progress, 0.5);
      expect(campaign1.isCompleted, isFalse);
      expect(campaign1.isOngoing, isTrue);
      expect(campaign1.formattedDonors, '150');
      expect(campaign1.formattedRaised, '₹25K');
      expect(campaign1.formattedGoal, '₹50K');
    });

    test('parses K and M suffix amounts correctly', () {
      final campaignK = HomeCampaign(goal: '100K', raised: '20K');
      expect(campaignK.goalAmount, 100000.0);
      expect(campaignK.raisedAmount, 20000.0);

      final campaignM = HomeCampaign(goal: '2M', raised: '1.5M');
      expect(campaignM.goalAmount, 2000000.0);
      expect(campaignM.raisedAmount, 1500000.0);
    });

    test('clamps progress to 1.0 when raised exceeds goal', () {
      final campaign = HomeCampaign(goal: '1000', raised: '1500');
      expect(campaign.isCompleted, isTrue);
      expect(campaign.isOngoing, isFalse);
      expect(campaign.progress, 1.0);
    });

    test('prevents divide by zero when goal is zero or invalid', () {
      final campaign = HomeCampaign(goal: '0', raised: '0');
      expect(campaign.goalAmount, 1.0);
      expect(campaign.progress, 0.0);
    });

    test('formats donors count >= 1000 with K suffix', () {
      final campaign = HomeCampaign(donorsCount: 2500);
      expect(campaign.formattedDonors, '2.5K');
    });
  });

  group('HomeDonationHistory Model', () {
    test('correctly identifies Daan donations by type, category, or title', () {
      final daan1 = HomeDonationHistory(type: 'Daan', item: 'Annadan Seva');
      expect(daan1.isDaan, isTrue);
      expect(daan1.isNgo, isFalse);
      expect(daan1.isCampaign, isFalse);

      final daan2 = HomeDonationHistory(fundCategory: 'Gau Seva', item: 'Cow Feed');
      expect(daan2.isDaan, isTrue);

      final daan3 = HomeDonationHistory(item: 'Feed Brahmin Seva');
      expect(daan3.isDaan, isTrue);
    });

    test('correctly identifies NGO donations', () {
      final ngoDonation1 = HomeDonationHistory(type: 'NGO', item: 'Direct NGO Donation');
      expect(ngoDonation1.isNgo, isTrue);
      expect(ngoDonation1.isDaan, isFalse);
      expect(ngoDonation1.isCampaign, isFalse);

      final ngoDonation2 = HomeDonationHistory(item: 'Care Foundation Trust');
      expect(ngoDonation2.isNgo, isTrue);
      expect(ngoDonation2.isCampaign, isFalse);
    });

    test('identifies regular donations as Campaign when neither Daan nor NGO', () {
      final campaignTxn = HomeDonationHistory(type: 'Campaign', item: 'Clean Drinking Water Initiative');
      expect(campaignTxn.isCampaign, isTrue);
      expect(campaignTxn.isDaan, isFalse);
      expect(campaignTxn.isNgo, isFalse);
    });

    test('parses parsedDate from ISO date or createdAt string', () {
      final item1 = HomeDonationHistory(date: '2026-10-10T14:30:00.000Z');
      expect(item1.parsedDate, isNotNull);
      expect(item1.parsedDate!.year, 2026);
      expect(item1.parsedDate!.month, 10);
      expect(item1.parsedDate!.day, 10);

      final item2 = HomeDonationHistory(date: null, createdAt: '2025-05-01T10:00:00.000Z');
      expect(item2.parsedDate, isNotNull);
      expect(item2.parsedDate!.year, 2025);
      expect(item2.parsedDate!.month, 5);

      final item3 = HomeDonationHistory(date: null, createdAt: null);
      expect(item3.parsedDate, isNull);
    });

    test('timeAgo calculates relative time from date string', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 2)).toIso8601String();
      final twoDaysAgo = now.subtract(const Duration(days: 3)).toIso8601String();

      expect(HomeDonationHistory(date: oneHourAgo).timeAgo, '2h ago');
      expect(HomeDonationHistory(date: twoDaysAgo).timeAgo, '3d ago');
      expect(HomeDonationHistory(date: null).timeAgo, '');
    });
  });

  group('HomeModel - Serialization & Deserialization', () {
    test('fromJson parses nested collections successfully', () {
      final json = {
        'status': true,
        'message': 'Success',
        'data': {
          'user': {
            'name': 'Aditi Sharma',
            'email': 'aditi@example.com',
            'phone': '9876543210',
          },
          'categories': [
            {'_id': 'cat_1', 'name': 'Education', 'icon': 'https://example.com/edu.png'},
          ],
          'campaigns': [
            {
              '_id': 'camp_1',
              'title': 'School Supplies',
              'goal': '20000',
              'raised': '10000',
              'donorsCount': 50,
            }
          ],
          'donationHistory': [
            {
              'donationId': 'tx_123',
              'amount': 500,
              'status': 'Success',
              'item': 'Annadan Seva',
              'date': '2026-10-09T10:00:00Z',
            }
          ],
          'pressAndMedia': [
            {
              '_id': '6a3d4bec03b69810db60a548',
              'newsId': 'NWS-001',
              'title': 'Divine Admin launches Astro-Coaching Scholarship program',
              'source': 'Times of India',
              'content': 'The Divine spiritual coaching network has launched its state of the art scholarship program.',
              'imageUrl': '',
              'publishedDate': '2026-06-22T15:38:29.356Z',
              'date': '2026-06-22T15:38:29.356Z',
              'status': 'Published'
            }
          ],
          'totalDonateAmount': 1500,
        }
      };

      final homeModel = HomeModel.fromJson(json);
      expect(homeModel.status, isTrue);
      expect(homeModel.data, isNotNull);
      expect(homeModel.data!.user?.name, 'Aditi Sharma');
      expect(homeModel.data!.categories?.length, 1);
      expect(homeModel.data!.categories?.first.name, 'Education');
      expect(homeModel.data!.campaigns?.length, 1);
      expect(homeModel.data!.campaigns?.first.raisedAmount, 10000.0);
      expect(homeModel.data!.donationHistory?.length, 1);
      expect(homeModel.data!.donationHistory?.first.transactionId, 'tx_123');
      expect(homeModel.data!.donationHistory?.first.isDaan, isTrue);
      expect(homeModel.data!.pressAndMedia?.length, 1);
      expect(homeModel.data!.pressAndMedia?.first.title, 'Divine Admin launches Astro-Coaching Scholarship program');
      expect(homeModel.data!.pressAndMedia?.first.source, 'Times of India');
      expect(homeModel.data!.totalDonateAmount, 1500);
    });

    test('fromJson handles null or empty data safely', () {
      final homeModel = HomeModel.fromJson({'status': false});
      expect(homeModel.status, isFalse);
      expect(homeModel.data, isNull);
    });

    test('HomePressMedia model parses fields and handles fallback id and image safely', () {
      final media = HomePressMedia.fromJson({
        'id': 'pm_123',
        'title': 'Test News',
        'image': 'https://example.com/test.jpg',
      });
      expect(media.id, 'pm_123');
      expect(media.title, 'Test News');
      expect(media.imageUrl, 'https://example.com/test.jpg');
      expect(media.toJson()['id'], 'pm_123');
    });
  });
}
