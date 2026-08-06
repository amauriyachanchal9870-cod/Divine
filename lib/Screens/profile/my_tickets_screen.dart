import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';
import '../../Controller/profile_controller.dart';
import '../../Model/support_ticket_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.fetchTicketsList(context);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      String daySuffix(int day) {
        if (day >= 11 && day <= 13) return 'th';
        switch (day % 10) {
          case 1: return 'st';
          case 2: return 'nd';
          case 3: return 'rd';
          default: return 'th';
        }
      }
      int hour = dt.hour;
      String period = 'am';
      if (hour >= 12) {
        period = 'pm';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;
      String minute = dt.minute.toString().padLeft(2, '0');
      
      return "${dt.day}${daySuffix(dt.day)} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.myTickets.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (_profileController.isTicketsLoading.value && _profileController.ticketsList.isEmpty) {
              return Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: AppTheme.primaryDeepBlue,
                  size: 50,
                ),
              );
            }
            if (_profileController.ticketsList.isEmpty) {
              return _buildEmptyTicketsState();
            }
            return RefreshIndicator(
              onRefresh: () => _profileController.fetchTicketsList(context),
              color: AppTheme.primaryDeepBlue,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                itemCount: _profileController.ticketsList.length,
                itemBuilder: (context, index) {
                  final ticket = _profileController.ticketsList[index];
                  return _buildTicketCard(ticket);
                },
              ),
            );
          }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
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
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDeepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => _showRaiseTicketSheet(context),
                    child: Text(
                      AppString.raiseTicket.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTicketsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.support_agent, size: 80, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            AppString.youDoNotHaveTickets.tr,
            style: AppFonts.mediumText.copyWith(color: AppTheme.textGrey500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showRaiseTicketSheet(BuildContext context) {
    _messageController.clear();
    _selectedCategory = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppString.raiseTicket.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.searchBarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          hint: Text(AppString.selectCategory.tr, style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500)),
                          items: <String>['Donation Issue', 'Technical Bug', 'Account Query', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setStateSheet(() {
                              _selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.searchBarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.fieldBorderColor),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppString.writeFeedback.tr,
                          hintStyle: AppFonts.regularText.copyWith(color: AppTheme.textGrey400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDeepBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (_selectedCategory == null) {
                            Get.snackbar(
                              "Required",
                              "Please select a category",
                              backgroundColor: AppTheme.redColor,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (_messageController.text.trim().isEmpty) {
                            Get.snackbar(
                              "Required",
                              "Please write your feedback/message",
                              backgroundColor: AppTheme.redColor,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          Get.back(); // Close bottom sheet
                          
                          bool success = await _profileController.raiseSupportTicket(
                            context: context,
                            subject: _selectedCategory!,
                            message: _messageController.text.trim(),
                          );

                          if (success) {
                            Get.snackbar(
                              "Success",
                              "Support ticket submitted successfully",
                              backgroundColor: AppTheme.greenColor,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          AppString.submit.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusBgColor;
    Color statusTextColor;
    
    switch (ticket.status?.toLowerCase()) {
      case 'solved':
      case 'resolved':
      case 'closed':
        statusBgColor = const Color(0xFFF0FDF4); // Light Green
        statusTextColor = const Color(0xFF16A34A); // Green
        break;
      case 'cancel':
      case 'cancelled':
        statusBgColor = const Color(0xFFFEF2F2); // Light Red
        statusTextColor = const Color(0xFFDC2626); // Red
        break;
      case 'open':
      case 'pending':
      default:
        statusBgColor = const Color(0xFFFFF7ED); // Light Orange
        statusTextColor = const Color(0xFFEA580C); // Orange
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.fieldBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.subject ?? "Support Ticket",
                style: AppFonts.semiBoldText.copyWith(fontSize: 15, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  ticket.status ?? "Open",
                  style: AppFonts.mediumText.copyWith(fontSize: 11, color: statusTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.ticketId ?? "",
                style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
              ),
              Text(
                _formatDate(ticket.createdAt),
                style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.message ?? "",
            style: AppFonts.regularText.copyWith(fontSize: 13, color: AppTheme.textGrey500, height: 1.4),
          ),
          if (ticket.reply != null && ticket.reply!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Reply",
                    style: AppFonts.semiBoldText.copyWith(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.reply!,
                    style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
