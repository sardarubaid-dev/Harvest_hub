import os
import re

def clean_file(path):
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Let's replace specific known corrupted things first
    content = content.replace('?', '•')
    content = content.replace('?"', '-')
    
    # Strip any remaining emojis or weird high unicode chars
    # We'll replace characters outside standard ASCII printable range, except for newlines and tabs
    def replacer(match):
        return '-'
    
    content = re.sub(r'[^\x00-\x7F]+', '-', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

clean_file('lib/screens/customer/cart_screen.dart')
clean_file('lib/screens/customer/customer_home_screen.dart')
print("Cleaned up emojis")
