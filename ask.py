with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# Find Ask button block. It's likely a container inside a row.
# Let's search for the Row containing 'Follow' and 'Ask'
idx = content.find("'Ask'")
print(content[idx-400:idx+400])

