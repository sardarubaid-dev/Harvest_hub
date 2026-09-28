import re
with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

match = re.search(r'(Future<OrderModel> placeOrder.*?\n  })', content, re.DOTALL)
if match:
    print(match.group(1))
else:
    print("Not found")
