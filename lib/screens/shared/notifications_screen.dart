import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notification_model.dart';
import '../../services/database_service.dart';

class NotificationsScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  NotificationsScreen({Key? key}) : super(key: key);

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()} y ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()} m ago";
    if (diff.inDays > 7) return "${(diff.inDays / 7).floor()} w ago";
    if (diff.inDays > 0) return "${diff.inDays} d ago";
    if (diff.inHours > 0) return "${diff.inHours} h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} min ago";
    return "just now";
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order_status':
      case 'order':
        return Icons.local_shipping_outlined;
      case 'restock':
        return Icons.inventory_2_outlined;
      case 'promo':
      case 'offer':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getColorForType(String type, Color primaryGreen) {
    switch (type.toLowerCase()) {
      case 'order_status':
      case 'order':
        return Colors.blue.shade600;
      case 'restock':
        return Colors.orange.shade600;
      case 'promo':
      case 'offer':
        return Colors.purple.shade600;
      default:
        return primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF191D19);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please login to view notifications')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: primaryGreen),
            tooltip: 'Mark all as read',
            onPressed: () {
              _dbService.markAllNotificationsAsRead(uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All marked as read'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _dbService.streamNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: Icon(Icons.notifications_none, size: 60, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  const Text('No new notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 8),
                  Text('We\'ll let you know when something arrives.', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            physics: const BouncingScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif.isRead;
              final iconColor = _getColorForType(notif.type, primaryGreen);

              return Dismissible(
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (direction) {
                  _dbService.deleteNotification(notif.id);
                },
                child: GestureDetector(
                  onTap: () {
                    if (!isRead) _dbService.markNotificationAsRead(notif.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : iconColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: isRead ? Border.all(color: Colors.transparent) : Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? const Color(0xFFF4F7F4) : iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getIconForType(notif.type), color: isRead ? Colors.grey.shade600 : iconColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(fontSize: 16, fontWeight: isRead ? FontWeight.w600 : FontWeight.w900, color: darkText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _timeAgo(notif.createdAt),
                                    style: TextStyle(fontSize: 12, color: isRead ? Colors.grey.shade500 : iconColor, fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.message,
                                style: TextStyle(fontSize: 14, color: isRead ? Colors.grey.shade600 : darkText.withOpacity(0.9), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
