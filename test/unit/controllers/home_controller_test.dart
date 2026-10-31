import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:divine_foundation/Controller/home_controller.dart';
import 'package:divine_foundation/Model/home_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    controller = HomeController();
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController - Filter State Management', () {
    test('initializes with default filter states', () {
      expect(controller.selectedDonationFilter.value, 'All');
      expect(controller.selectedDonationType.value, 'All');
      expect(controller.donationStartDate.value, isNull);
      expect(controller.donationEndDate.value, isNull);
      expect(controller.donationSearchQuery.value, '');
      expect(controller.hasActiveDonationFilters, isFalse);
    });

    test('hasActiveDonationFilters returns true when any filter is modified', () {
      controller.selectedDonationType.value = 'Campaign';
      expect(controller.hasActiveDonationFilters, isTrue);

      controller.selectedDonationType.value = 'All';
      expect(controller.hasActiveDonationFilters, isFalse);

      controller.donationStartDate.value = DateTime(2026, 1, 1);
      expect(controller.hasActiveDonationFilters, isTrue);

      controller.clearDonationDateRange();
      expect(controller.hasActiveDonationFilters, isFalse);

      controller.donationSearchQuery.value = 'Food';
      expect(controller.hasActiveDonationFilters, isTrue);
    });

    test('setDonationDateRange and clearDonationDateRange set and clear dates', () {
      final start = DateTime(2026, 10, 1);
      final end = DateTime(2026, 10, 10);

      controller.setDonationDateRange(start, end);
      expect(controller.donationStartDate.value, start);
      expect(controller.donationEndDate.value, end);

      controller.clearDonationDateRange();
      expect(controller.donationStartDate.value, isNull);
      expect(controller.donationEndDate.value, isNull);
    });

    test('clearAllDonationFilters resets all filter state variables to defaults', () {
      controller.selectedDonationFilter.value = 'Payment Logs';
      controller.selectedDonationType.value = 'Daan';
      controller.setDonationDateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 10));
      controller.donationSearchQuery.value = 'Annadan';

      expect(controller.hasActiveDonationFilters, isTrue);

      controller.clearAllDonationFilters();

      expect(controller.selectedDonationFilter.value, 'All');
      expect(controller.selectedDonationType.value, 'All');
      expect(controller.donationStartDate.value, isNull);
      expect(controller.donationEndDate.value, isNull);
      expect(controller.donationSearchQuery.value, '');
      expect(controller.hasActiveDonationFilters, isFalse);
    });
  });

  group('HomeController - filteredDonationHistory Business Logic', () {
    setUp(() {
      controller.homeData.value = HomeData(
          donationHistory: [
            HomeDonationHistory(
              transactionId: 'TX1',
              item: 'Clean Water Campaign',
              type: 'Campaign',
              amount: 500,
              status: 'Success',
              date: '2026-10-01T10:00:00Z',
            ),
            HomeDonationHistory(
              transactionId: 'TX2',
              item: 'Annadan Food Seva',
              type: 'Daan',
              amount: 300,
              status: 'Success',
              date: '2026-10-05T12:00:00Z',
            ),
            HomeDonationHistory(
              transactionId: 'TX3',
              item: 'Direct NGO Relief Trust',
              type: 'NGO',
              amount: 1000,
              status: 'Success',
              date: '2026-10-09T15:00:00Z',
            ),
            HomeDonationHistory(
              transactionId: 'TX4',
              item: 'Wallet Topup Seva',
              type: 'Daan',
              amount: 200,
              status: 'Success',
              date: '2026-10-10T09:00:00Z',
            ),
          ],
        );
    });

    test('returns all donation history items when no filters are active', () {
      expect(controller.filteredDonationHistory.length, 4);
    });

    test('filters correctly by Donation Type (Campaign, Daan, NGO)', () {
      controller.selectedDonationType.value = 'Campaign';
      expect(controller.filteredDonationHistory.length, 1);
      expect(controller.filteredDonationHistory.first.transactionId, 'TX1');

      controller.selectedDonationType.value = 'Daan';
      expect(controller.filteredDonationHistory.length, 2);
      expect(controller.filteredDonationHistory.first.transactionId, 'TX2');

      controller.selectedDonationType.value = 'NGO';
      expect(controller.filteredDonationHistory.length, 1);
      expect(controller.filteredDonationHistory.first.transactionId, 'TX3');
    });

    test('filters correctly by Date Range (Start Date to End Date)', () {
      // 03 Oct to 08 Oct should only include TX2 (05 Oct)
      controller.setDonationDateRange(
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 8),
      );

      final result = controller.filteredDonationHistory;
      expect(result.length, 1);
      expect(result.first.transactionId, 'TX2');
    });

    test('filters correctly by Tab (Payment Logs)', () {
      controller.selectedDonationFilter.value = 'Payment Logs';
      final logs = controller.filteredDonationHistory;
      expect(logs.any((t) => t.item!.contains('Wallet Topup')), isTrue);
    });

    test('filters correctly by search query', () {
      controller.donationSearchQuery.value = 'Water';
      expect(controller.filteredDonationHistory.length, 1);
      expect(controller.filteredDonationHistory.first.transactionId, 'TX1');
    });

    test('pressAndMedia returns list from homeData safely', () {
      expect(controller.pressAndMedia, isEmpty);
      controller.homeData.value = HomeData(
        pressAndMedia: [
          HomePressMedia(id: '1', title: 'Press Release 1'),
        ],
      );
      expect(controller.pressAndMedia.length, 1);
      expect(controller.pressAndMedia.first.title, 'Press Release 1');
    });
  });
}
