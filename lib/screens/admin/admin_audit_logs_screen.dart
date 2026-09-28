import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/audit_log_model.dart';
import 'package:intl/intl.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Audit Logs', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: StreamBuilder<List<AuditLogModel>>(
        stream: _db.streamAuditLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No audit logs found.'));
          }

          final logs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.surfaceVariant),
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogItem(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogItem(AuditLogModel log) {
    final timeStr = DateFormat('MMM d, yyyy - h:mm a').format(log.timestamp);
    IconData icon;
    Color iconBg;
    Color iconColor;

    if (log.actionName.toLowerCase().contains('delete')) {
      icon = Icons.delete_outline;
      iconBg = AppColors.errorContainer;
      iconColor = AppColors.error;
    } else if (log.actionName.toLowerCase().contains('create') || log.actionName.toLowerCase().contains('broadcast')) {
      icon = Icons.add_circle_outline;
      iconBg = AppColors.secondaryContainer;
      iconColor = AppColors.onSecondaryContainer;
    } else {
      icon = Icons.edit_outlined;
      iconBg = AppColors.surfaceVariant;
      iconColor = AppColors.onSurfaceVariant;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.actionName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              if (log.details != null) ...[
                Text(
                  log.details!,
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '$timeStr • By: ${log.performedBy}',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
