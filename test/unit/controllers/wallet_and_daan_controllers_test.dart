import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:divine_foundation/Controller/wallet_controller.dart';
import 'package:divine_foundation/Controller/daan_controller.dart';
import 'package:divine_foundation/Controller/search_controller.dart';
import 'package:divine_foundation/Model/wallet_model.dart';
import 'package:divine_foundation/Model/dan_items_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('WalletController - Transaction Filtering Logic', () {
    late WalletController walletController;

    setUp(() {
      walletController = WalletController();
      walletController.transactions.assignAll([
        WalletTransaction(
          id: '1',
          item: 'Topup Wallet Via UPI',
          type: 'topup',
          amount: 500,
          status: 'completed',
        ),
        WalletTransaction(
          id: '2',
          item: 'Fundraising Campaign Donation',
          type: 'fundraising',
          amount: 250,
          status: 'completed',
        ),
        WalletTransaction(
          id: '3',
          item: 'Cashback Reward Credit',
          type: 'cashback',
          amount: 50,
          status: 'completed',
        ),
        WalletTransaction(
          id: '4',
          item: 'Monthly Expiry Bonus Deduction',
          type: 'bonus',
          amount: 10,
          status: 'completed',
        ),
      ]);
    });

    test('filters transactions by tab (Fundraising vs Donations)', () {
      walletController.selectedTab.value = 'Fundraising';
      final fundraisingList = walletController.filteredTransactions;
      expect(fundraisingList.length, 1);
      expect(fundraisingList.first.id, '2');

      walletController.selectedTab.value = 'Donations';
      expect(walletController.filteredTransactions.length, 4);
    });

    test('filters transactions by Payment Logs', () {
      walletController.selectedFilter.value = 'Payment Logs';
      final logs = walletController.filteredTransactions;
      expect(logs.any((t) => t.type == 'topup'), isTrue);
    });

    test('filters transactions by Cashback', () {
      walletController.selectedFilter.value = 'Cashback';
      final cashbackList = walletController.filteredTransactions;
      expect(cashbackList.length, 1);
      expect(cashbackList.first.id, '3');
    });

    test('filters transactions by Expiry Cashback', () {
      walletController.selectedFilter.value = 'Expiry Cashback';
      final expiryList = walletController.filteredTransactions;
      expect(expiryList.length, 1);
      expect(expiryList.first.id, '4');
    });

    test('filters transactions by search query', () {
      walletController.searchQuery.value = 'UPI';
      expect(walletController.filteredTransactions.length, 1);
      expect(walletController.filteredTransactions.first.id, '1');
    });

    test('initializes default recharge tiers correctly', () {
      expect(walletController.rechargeTiers.length, 5);
      expect(walletController.rechargeTiers[0].amount, 100);
      expect(walletController.rechargeTiers[1].amount, 500);
      expect(walletController.rechargeTiers[2].badgeText, 'Best Value');
    });
  });

  group('DaanController - Cart & Pricing Logic', () {
    late DaanController daanController;

    setUp(() {
      daanController = DaanController();
      daanController.danItems.assignAll([
        DanItemData(id: 'item_1', name: 'Ration Kit', price: 300),
        DanItemData(id: 'item_2', name: 'Cow Fodder', price: 200),
      ]);
    });

    test('incrementItem and decrementItem update item quantity map', () {
      expect(daanController.itemQtyMap['item_1'], isNull);

      daanController.incrementItem('item_1');
      expect(daanController.itemQtyMap['item_1'], 1);

      daanController.incrementItem('item_1');
      expect(daanController.itemQtyMap['item_1'], 2);

      daanController.decrementItem('item_1');
      expect(daanController.itemQtyMap['item_1'], 1);

      daanController.decrementItem('item_1');
      expect(daanController.itemQtyMap['item_1'], 0);

      // Decrementing at 0 stays at 0
      daanController.decrementItem('item_1');
      expect(daanController.itemQtyMap['item_1'], 0);
    });

    test('itemsTotal dynamically calculates total price from cart quantities', () {
      expect(daanController.itemsTotal, 0);

      daanController.incrementItem('item_1'); // 1 * 300 = 300
      expect(daanController.itemsTotal, 300);

      daanController.incrementItem('item_2'); // 1 * 200 = 200 -> total 500
      expect(daanController.itemsTotal, 500);

      daanController.incrementItem('item_1'); // 2 * 300 + 200 = 800
      expect(daanController.itemsTotal, 800);
    });

    test('cartPayload includes only items with quantity greater than zero', () {
      daanController.incrementItem('item_1');
      daanController.incrementItem('item_1');

      final payload = daanController.cartPayload;
      expect(payload.length, 1);
      expect(payload.first['itemId'], 'item_1');
      expect(payload.first['quantity'], 2);
    });
  });

  group('CampaignSearchController - Local Recent Searches', () {
    late CampaignSearchController searchController;

    setUp(() {
      searchController = CampaignSearchController();
      searchController.recentSearches.clear();
    });

    test('addRecentSearchLocal adds queries to head and prevents duplicates', () {
      searchController.addRecentSearchLocal('Education');
      searchController.addRecentSearchLocal('Health');
      expect(searchController.recentSearches, ['Health', 'Education']);

      // Adding existing query moves it to top without duplicating
      searchController.addRecentSearchLocal('Education');
      expect(searchController.recentSearches, ['Education', 'Health']);
    });

    test('addRecentSearchLocal limits list to maximum 5 items', () {
      for (int i = 1; i <= 7; i++) {
        searchController.addRecentSearchLocal('Query $i');
      }

      expect(searchController.recentSearches.length, 5);
      expect(searchController.recentSearches.first, 'Query 7');
      expect(searchController.recentSearches.last, 'Query 3');
    });

    test('removeRecentSearchLocal removes item', () {
      searchController.addRecentSearchLocal('Food');
      searchController.addRecentSearchLocal('Trees');

      searchController.removeRecentSearchLocal('Food');
      expect(searchController.recentSearches, ['Trees']);
    });
  });
}
