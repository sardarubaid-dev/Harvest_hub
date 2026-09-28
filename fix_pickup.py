import re

file_path = 'lib/screens/customer/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_pickup = """          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: primaryGreen, size: 16),
                const SizedBox(width: 8),
                const Text('Available 9:00 AM - 6:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              ],
            ),
          )"""

new_pickup = """          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: primaryGreen, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('Available 9:00 AM - 6:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), overflow: TextOverflow.ellipsis)),
              ],
            ),
          )"""
content = content.replace(old_pickup, new_pickup)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done pickup text")
