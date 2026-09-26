class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'system',
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? map['User_Id'] ?? '',
      title: map['title'] ?? map['Title'] ?? '',
      message: map['message'] ?? map['Message'] ?? '',
      type: map['type'] ?? map['Type'] ?? 'system',
      isRead: map['isRead'] ?? map['Is_Read'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'User_Id': userId,
      'title': title,
      'Title': title,
      'message': message,
      'Message': message,
      'type': type,
      'Type': type,
      'isRead': isRead,
      'Is_Read': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}