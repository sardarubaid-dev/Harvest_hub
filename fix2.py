with open('lib/screens/shared/product_card_widget.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('height: 120,', 'height: 130,')

content = content.replace('            Padding(\n              padding: const EdgeInsets.all(12),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [', '            Expanded(\n              child: Padding(\n                padding: const EdgeInsets.all(12),\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [')

content = content.replace('                  const SizedBox(height: 12),\n                  Row(\n                    mainAxisAlignment: MainAxisAlignment.spaceBetween,', '                  const Spacer(),\n                  Row(\n                    mainAxisAlignment: MainAxisAlignment.spaceBetween,')

# Now carefully find the end
# The end of the Column that we wrapped in Expanded is:
#               ],
#             ),
#           ),
#         ],
#       ),
#     ),
#   );
import re
end_pattern = r'              \),\n            \),\n          \],\n        \),\n      \),\n    \);\n\}'
match = re.search(end_pattern, content)
if match:
    content = content[:match.start()] + '                ),\n              ),\n            ),\n          ],\n        ),\n      ),\n    );\n}'
else:
    print("Could not find end block")

with open('lib/screens/shared/product_card_widget.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
