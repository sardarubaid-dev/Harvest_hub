import re

with open('lib/screens/shared/product_card_widget.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update image height and border
content = content.replace('height: 120,', 'height: 130,')

# 2. Add Expanded around the Padding that holds the texts
content = content.replace(
'''            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [''',
'''            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ['''
)

# 3. Change SizedBox(height: 12) to Spacer() for bottom alignment
content = content.replace(
'''                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,''',
'''                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,'''
)

# 4. Close the Expanded widget properly
content = content.replace(
'''              ),
            ),
          ],
        ),
      ),
    );''',
'''                ),
              ),
            ),
          ],
        ),
      ),
    );'''
)

with open('lib/screens/shared/product_card_widget.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed card layout")
