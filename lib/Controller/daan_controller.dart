import 'package:get/get.dart';

class DaanController extends GetxController {
  // Cart items quantity state
  var rationKitQty = 2.obs;
  var feedBrahminsQty = 0.obs;
  var dryRationsQty = 1.obs;

  // Pricing constants
  final int rationKitPrice = 300;
  final int feedBrahminsPrice = 300;
  final int dryRationsPrice = 200;

  // Selected Impact type: 'one_time' or 'monthly'
  var impactType = 'one_time'.obs;

  // Event Details
  var selectedEvent = 'Others'.obs; // Default to Others as shown in screenshot
  var eventName = ''.obs;
  var eventDate = ''.obs;
  var selectedCurrency = 'INR'.obs;
  var addDetailsChecked = true.obs;

  // Total calculation
  int get totalAmount {
    int total = 0;
    total += rationKitQty.value * rationKitPrice;
    total += feedBrahminsQty.value * feedBrahminsPrice;
    total += dryRationsQty.value * dryRationsPrice;
    return total;
  }

  // Count items
  int get saintsBrahminsItemCount => rationKitQty.value + feedBrahminsQty.value;
  int get saintsBrahminsTotal => (rationKitQty.value * rationKitPrice) + (feedBrahminsQty.value * feedBrahminsPrice);

  int get dryRationsItemCount => dryRationsQty.value;
  int get dryRationsTotal => dryRationsQty.value * dryRationsPrice;

  void resetAll() {
    rationKitQty.value = 2;
    feedBrahminsQty.value = 0;
    dryRationsQty.value = 1;
    impactType.value = 'one_time';
    selectedEvent.value = 'Others';
    eventName.value = '';
    eventDate.value = '';
    selectedCurrency.value = 'INR';
    addDetailsChecked.value = true;
  }
}
