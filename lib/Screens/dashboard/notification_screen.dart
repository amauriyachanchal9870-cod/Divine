import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utilities/app_theme.dart';
import '../../Utilities/app_string.dart';
import '../../Utilities/app_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "name": "Jordan Lee",
        "time": "Just now",
        "action": "Uploaded a document for the Product launch",
        "unread": true,
      },
      {
        "name": "Maya Chen",
        "time": "3 mins ago",
        "action": "Added Chris Morgan to the project team",
        "unread": true,
      },
      {
        "name": "Alex Johnson",
        "time": "3 mins ago",
        "action": "Added Chris Morgan to the project team",
        "unread": true,
      },
      {
        "name": "Sophie Turner",
        "time": "4 hours ago",
        "action": "Commented on the Product launch",
        "unread": true,
      },
      {
        "name": "Sophie Turner",
        "time": "4 hours ago",
        "action": "Was assigned to the Product launch",
        "unread": false,
      },
      {
        "name": "Liam Smith",
        "time": "7 hours ago",
        "action": "Created 5 tasks for the Product launch",
        "unread": false,
      },
      {
        "name": "Liam Smith",
        "time": "7 hours ago",
        "action": "Invited Maya Chen to the project team",
        "unread": false,
      },
      {
        "name": "Oliver Brown",
        "time": "12 hours ago",
        "action": "Uploaded a document for the Product launch",
        "unread": false,
      },
      {
        "name": "Ella White",
        "time": "13 hours ago",
        "action": "Uploaded a document for the Product launch",
        "unread": false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(AppString.notification.tr, style: AppFonts.titleStyle.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.fieldBorderColor,
                  backgroundImage: const AssetImage('assets/images/ngo_logo.png'), // Placeholder
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['name'],
                            style: AppFonts.semiBoldText.copyWith(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['time'],
                            style: AppFonts.regularText.copyWith(fontSize: 12, color: AppTheme.textGrey500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['action'],
                        style: AppFonts.regularText.copyWith(fontSize: 14, color: AppTheme.textGrey500, height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (item['unread'] == true) ...[
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5), // Vibrant green from design
                      shape: BoxShape.circle,
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
