import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/daan_controller.dart';
import '../../Routes/my_routes.dart';

class ReviewPayScreen extends StatelessWidget {
  const ReviewPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DaanController controller = Get.find<DaanController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Review & Pay",
          style: AppFonts.titleStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cart Items",
                          style: AppFonts.semiBoldText.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        // One Time / Monthly toggle pill
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // Light green background
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.impactType.value = 'one_time',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: controller.impactType.value == 'one_time'
                                        ? const Color(0xFF2E7D32) // Dark green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    "One Time",
                                    style: TextStyle(
                                      color: controller.impactType.value == 'one_time' ? Colors.white : const Color(0xFF2E7D32),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.impactType.value = 'monthly',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: controller.impactType.value == 'monthly'
                                        ? const Color(0xFF2E7D32)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    "Monthly",
                                    style: TextStyle(
                                      color: controller.impactType.value == 'monthly' ? Colors.white : const Color(0xFF2E7D32),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCartItemList(controller),
                    const SizedBox(height: 12),
                    _buildAddMoreItemsButton(),
                    const SizedBox(height: 24),

                    // Event Details Section
                    Text("Select Event Details", style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildEventDropdown(controller, context),
                    const SizedBox(height: 8),
                    
                    // Add Details checkbox row
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: controller.addDetailsChecked.value,
                            onChanged: (val) {
                              if (val != null) {
                                controller.addDetailsChecked.value = val;
                              }
                            },
                            activeColor: AppTheme.primaryDeepBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Add Details",
                          style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Animated/conditional display of Event fields
                    if (controller.addDetailsChecked.value) ...[
                      Text("Event Name", style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildEventNameInput(controller),
                      const SizedBox(height: 16),
                      Text("Event Date", style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildEventDatePicker(controller, context),
                      const SizedBox(height: 16),
                    ],

                    // Currency Section
                    Text("Currency", style: AppFonts.semiBoldText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCurrencySelector(controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(controller),
          ],
        );
      }),
    );
  }

  Widget _buildCartItemList(DaanController controller) {
    List<Widget> itemsList = [];

    if (controller.rationKitQty.value > 0) {
      itemsList.add(
        _buildCartItem(
          title: "Ration Kit For Needy Family - 30days",
          subtitle: "Saints & Brahmins Seva",
          price: controller.rationKitPrice,
          qty: controller.rationKitQty.value,
          impactType: controller.impactType.value,
          imagePath: 'assets/images/campaign_image.png',
        ),
      );
    }

    if (controller.feedBrahminsQty.value > 0) {
      if (itemsList.isNotEmpty) itemsList.add(const SizedBox(height: 12));
      itemsList.add(
        _buildCartItem(
          title: "Feed Brahmins And Saints",
          subtitle: "Saints & Brahmins Seva",
          price: controller.feedBrahminsPrice,
          qty: controller.feedBrahminsQty.value,
          impactType: controller.impactType.value,
          imagePath: 'assets/images/campaign_image.png',
        ),
      );
    }

    if (controller.dryRationsQty.value > 0) {
      if (itemsList.isNotEmpty) itemsList.add(const SizedBox(height: 12));
      itemsList.add(
        _buildCartItem(
          title: "Dry Rations Kit",
          subtitle: "Dry Rations Seva",
          price: controller.dryRationsPrice,
          qty: controller.dryRationsQty.value,
          impactType: controller.impactType.value,
          imagePath: 'assets/images/campaign_image.png',
        ),
      );
    }

    return Column(children: itemsList);
  }

  Widget _buildCartItem({
    required String title,
    required String subtitle,
    required int price,
    required int qty,
    required String impactType,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.regularText.copyWith(fontSize: 10, color: AppTheme.textGrey500),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$qty X ₹ $price / Unit",
                      style: AppFonts.regularText.copyWith(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹ ${qty * price}",
                      style: AppFonts.semiBoldText.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryDeepBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreItemsButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryDeepBlue),
            const SizedBox(width: 6),
            Text(
              "Add More Items",
              style: AppFonts.semiBoldText.copyWith(fontSize: 13, color: AppTheme.primaryDeepBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDropdown(DaanController controller, BuildContext context) {
    final events = ["Birthday", "Anniversary", "Occasion", "In Memory", "Festival", "Shradh / Punya Tithi", "Others"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedEvent.value,
          isExpanded: true,
          items: events.map((event) {
            return DropdownMenuItem<String>(
              value: event,
              child: Text(event, style: AppFonts.regularText.copyWith(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedEvent.value = val;
            }
          },
        ),
      ),
    );
  }

  Widget _buildEventNameInput(DaanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: (val) => controller.eventName.value = val,
        style: AppFonts.regularText.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Enter Event Name",
          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEventDatePicker(DaanController controller, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.eventDate.value = DateFormat('dd/MM/yyyy').format(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.fieldBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.eventDate.value.isEmpty ? "dd/mm/yyyy" : controller.eventDate.value,
              style: AppFonts.regularText.copyWith(
                color: controller.eventDate.value.isEmpty ? AppTheme.textGrey400 : Colors.black87,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(DaanController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.fieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                controller.selectedCurrency.value,
                style: AppFonts.semiBoldText.copyWith(fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              // Show a flag icon of India
              const Text("🇮🇳", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                "India",
                style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DaanController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDeepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              // Set the total amount parameter and navigate to payment method screen
              Get.toNamed(
                MyRouters.paymentMethodScreen,
                arguments: {'amount': controller.totalAmount.toString()},
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Donate now",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                          Text(
                            "₹ ${controller.totalAmount}",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
