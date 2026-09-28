import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String actionName;
  final String performedBy;
  final String? targetId;
  final String? details;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.actionName,
    required this.performedBy,
    this.targetId,
    this.details,
    required this.timestamp,
  });

  factory AuditLogModel.fromMap(String id, Map<String, dynamic> map) {
    return AuditLogModel(
      id: id,
      actionName: map['actionName'] ?? '',
      performedBy: map['performedBy'] ?? 'System',
      targetId: map['targetId'],
      details: map['details'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actionName': actionName,
      'performedBy': performedBy,
      'targetId': targetId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
