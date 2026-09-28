import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class FarmerNotificationsScreen extends StatefulWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  State<FarmerNotificationsScreen> createState() =>
      _FarmerNotificationsScreenState();
}

class _FarmerNotificationsScreenState extends State<FarmerNotificationsScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _filter = 'all'; 

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
      case 'order_status':
        return Icons.shopping_bag_outlined;
      case 'restock':
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'alert':
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
      case 'order_status':
        return AppColors.primary;
      case 'restock':
      case 'inventory':
        return const Color(0xFF1976D2);
      case 'alert':
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final farmer = authProvider.currentFarmer;

    final String targetUserId = farmer?.userId.isNotEmpty == true
        ? farmer!.userId
        : (user?.uid ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (targetUserId.isNotEmpty) {
                await _dbService.markAllNotificationsAsRead(targetUserId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == 'all',
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: TextStyle(
                    color: _filter == 'all' ? Colors.white : AppColors.onSurface,
                    fontWeight: _filter == 'all' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'all');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Unread Only'),
                  selected: _filter == 'unread',
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: TextStyle(
                    color: _filter == 'unread' ? Colors.white : AppColors.onSurface,
                    fontWeight: _filter == 'unread' ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'unread');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceVariant),

          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _dbService.streamUserNotifications(targetUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading notifications',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];
                final filtered = notifications.where((n) {
                  if (_filter == 'unread') return !n.isRead;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 64,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'unread'
                              ? 'No unread notifications'
                              : 'No notifications received yet',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Order updates and farm alerts will appear here.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.surfaceVariant),
                  itemBuilder: (context, index) {
                    final notif = filtered[index];
                    final color = _getNotificationColor(notif.type);
                    final icon = _getNotificationIcon(notif.type);
                    final timeStr = DateFormat('dd MMM, hh:mm a').format(notif.createdAt);

                    return InkWell(
                      onTap: () {
                        if (!notif.isRead) {
                          _dbService.markNotificationAsRead(notif.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        color: notif.isRead
                            ? AppColors.surface
                            : AppColors.onTertiaryContainer.withValues(alpha: 0.6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: notif.isRead
                                                ? FontWeight.w600
                                                : FontWeight.bold,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (!notif.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
