import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/notification_model.dart';
import 'package:harvest_hub/models/audit_log_model.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _db = DatabaseService();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  
  String _selectedAudience = 'all'; // 'all', 'customers', 'farmers'
  bool _isSending = false;

  Future<void> _sendBroadcast() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and message body.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Create notification in DB
      // Note: A real backend would likely fan-out this to all users, but here we can just create
      // one generic notification, or simulate by creating for 'broadcast' topic.
      // We will create a notification object with userId = 'BROADCAST_$_selectedAudience'
      
      await _db.sendNotification(
        userId: 'BROADCAST_$_selectedAudience',
        title: title,
        message: body,
        type: 'system',
      );

      await _db.logAdminAction(AuditLogModel(
        id: '',
        actionName: 'Notice Broadcasted',
        performedBy: 'Admin',
        details: 'Broadcast sent to $_selectedAudience: $title',
        timestamp: DateTime.now(),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send broadcast: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Broadcast Notice', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target Audience',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('All Users'),
                    value: 'all',
                    groupValue: _selectedAudience,
                    activeColor: AppColors.primaryContainer,
                    onChanged: (v) => setState(() => _selectedAudience = v.toString()),
                  ),
                  RadioListTile(
                    title: const Text('Customers Only'),
                    value: 'customers',
                    groupValue: _selectedAudience,
                    activeColor: AppColors.primaryContainer,
                    onChanged: (v) => setState(() => _selectedAudience = v.toString()),
                  ),
                  RadioListTile(
                    title: const Text('Farmers Only'),
                    value: 'farmers',
                    groupValue: _selectedAudience,
                    activeColor: AppColors.primaryContainer,
                    onChanged: (v) => setState(() => _selectedAudience = v.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Notice Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Notice Title',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message Body',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                label: Text(_isSending ? 'Sending...' : 'Send Broadcast', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _isSending ? null : _sendBroadcast,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
