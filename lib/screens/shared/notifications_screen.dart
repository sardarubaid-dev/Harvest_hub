import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/notification_model.dart';
import '../../services/database_service.dart';

class NotificationsScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please login to view notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _dbService.streamNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif.isRead;
              final timeStr = notif.createdAt.toString().substring(0, 16);

              return ListTile(
                tileColor: isRead ? Colors.transparent : Colors.green.withOpacity(0.08),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.notifications, color: Colors.green),
                ),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${notif.message}\n$timeStr',
                  style: const TextStyle(height: 1.5),
                ),
                isThreeLine: true,
                onTap: () {
                  if (!isRead) {
                    _dbService.markNotificationAsRead(notif.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
