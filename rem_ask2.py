with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# We know where 'Ask' is. Let's just delete the container that contains it.
idx = content.find("'Ask'")
# Go backwards to find `Container(`
start_idx = content.rfind('Container(', 0, idx)
# And maybe there's a SizedBox before it
start_box = content.rfind('const SizedBox(width: 8),', 0, start_idx)

if start_box != -1 and start_box > start_idx - 100:
    start_idx = start_box

# Now find the end of the container. 
# It has child: Row( children: const [ Icon(), SizedBox(), Text('Ask', ...) ] )
# We can just look for the first `,` or `)` after `]` or something.
end_idx = content.find('),', content.find(']', idx))
end_idx = content.find('),', end_idx + 1)
end_idx = content.find(',', end_idx + 1)

content = content[:start_idx] + content[end_idx+1:]

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Removed Ask by manual index")
