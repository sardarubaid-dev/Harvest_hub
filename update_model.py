import sys

file_path = r'c:\Users\Dr.pc\Desktop\harvest_hub\lib\models\product_model.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import re
# Add marketName field
content = re.sub(r'final String\? farmerName;\n', r'final String? farmerName;\n  final String? marketName;\n', content)
content = re.sub(r'this\.farmerName,\n', r'this.farmerName,\n    this.marketName,\n', content)
content = re.sub(r'farmerName: map\[\'farmerName\'\] \?\? map\[\'Farmer_Name\'\],\n', r'farmerName: map[\'farmerName\'] ?? map[\'Farmer_Name\'],\n      marketName: map[\'marketName\'] ?? map[\'Market_Name\'],\n', content)
content = re.sub(r'\'farmerName\': farmerName,\n', r'\'farmerName\': farmerName,\n      \'marketName\': marketName,\n', content)
content = re.sub(r'String\? farmerName,\n', r'String? farmerName,\n    String? marketName,\n', content)
content = re.sub(r'farmerName: farmerName \?\? this\.farmerName,\n', r'farmerName: farmerName ?? this.farmerName,\n      marketName: marketName ?? this.marketName,\n', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
