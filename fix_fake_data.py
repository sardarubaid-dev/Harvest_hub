import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the whole _customerReviews list declaration with an empty list
pattern = r'final List<Map<String, dynamic>> _customerReviews = \[.*?\];'
new_val = 'final List<Map<String, dynamic>> _customerReviews = [];'
content = re.sub(pattern, new_val, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('done')
