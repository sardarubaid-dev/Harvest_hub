import re

with open('lib/screens/customer/order_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('_farmer!.profileImageUrl?.isEmpty ?? true', '_farmer!.profileImageUrl == null || _farmer!.profileImageUrl!.isEmpty')
c = c.replace('_farmer!.profileImageUrl.isEmpty', '(_farmer!.profileImageUrl?.isEmpty ?? true)')


with open('lib/screens/customer/order_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

with open('lib/services/database_service.dart', 'a', encoding='utf-8') as f:
    f.write('''
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}
''')

# Wait, the database_service.dart already has `}` at the end! So appending will put it after the class!
# Let me replace the last `}` instead.
with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    d = f.read()

d = d.rstrip()
if d.endswith('}'):
    d = d[:-1] + '''
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
    });
  }
}
'''
with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.write(d)
