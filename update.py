import sys

file_path = r'c:\Users\Dr.pc\Desktop\harvest_hub\lib\screens\customer\product_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import re
old_text = r'''                                      onPressed: \(\) \{
                                        final farmerName =
                                            widget\.product\?\['farmerName'\] \?\? '';
                                        final farmerData = <String, dynamic>\{
                                          'id': 'f0',
                                          'name': farmerName,
                                          'rating': '5\.0',
                                          'reviews': '120 reviews',
                                          'location': 'Local Farm',
                                          'isFollowing': false,
                                        \};'''

new_text = '''                                      onPressed: () {
                                        final farmerName =
                                            widget.product?['farmerName'] ?? '';
                                        final farmerData = <String, dynamic>{
                                          'id': widget.product?['farmerId'] ?? 'f0',
                                          'name': farmerName,
                                          'rating': '5.0',
                                          'reviews': '120 reviews',
                                          'location': 'Local Farm',
                                          'isFollowing': false,
                                        };'''

content = re.sub(old_text, new_text, content)
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
