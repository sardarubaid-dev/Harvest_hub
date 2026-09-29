import re

file_path = 'lib/services/database_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_mark = """  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }"""
new_mark = """  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }"""
content = content.replace(old_mark, new_mark)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("added deleteNotification")
