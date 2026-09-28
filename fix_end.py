import re

with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the closing brace of the class DatabaseService
# It should be around line 856
last_closing_brace_index = -1
for i in range(len(lines)):
    if 'class DatabaseService' in lines[i]:
        pass
    if lines[i].strip() == '}':
        last_closing_brace_index = i

# Truncate and insert
lines = lines[:last_closing_brace_index]
lines.append('''  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
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
''')

with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
