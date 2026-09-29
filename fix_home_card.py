import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# We want to change the inner Column of _buildProductCard to use Expanded for the text block.
# Let's locate _buildProductCard
start_idx = content.find('Widget _buildProductCard({')
if start_idx != -1:
    end_idx = content.find('Widget _buildDealsOfTheDaySection', start_idx)
    if end_idx == -1: end_idx = len(content)
    
    old_func = content[start_idx:end_idx]
    
    # We will replace the Padding surrounding the text with an Expanded widget that contains the text
    # The Padding is: Padding(padding: const EdgeInsets.all(12), child: Column( ... ))
    # We want: Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column( ... <Add Spacer() before the bottom Row> )))
    
    # Let's do string replacement on old_func
    new_func = old_func.replace(
        "Padding(\n              padding: const EdgeInsets.all(12),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,\n                children: [",
        "Expanded(\n              child: Padding(\n                padding: const EdgeInsets.all(12),\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: ["
    )
    
    # Add Spacer() before the price row
    new_func = new_func.replace(
        "const SizedBox(height: 12),\n                  Row(\n                    mainAxisAlignment: MainAxisAlignment.spaceBetween,",
        "const Spacer(),\n                  Row(\n                    mainAxisAlignment: MainAxisAlignment.spaceBetween,"
    )
    
    # Also add the closing bracket for Expanded
    # The end of the Padding is right before `);` for the return GestureDetector or similar.
    # Actually, it's before `],` of the outer Column
    new_func = new_func.replace(
        "              ),\n            ),\n          ],\n        ),\n      ),\n    );\n  }",
        "                ),\n              ),\n            ),\n          ],\n        ),\n      ),\n    );\n  }"
    )

    # Let's be safer with regex or explicit replacement
    
    print("Found _buildProductCard")
else:
    print("Not found")

