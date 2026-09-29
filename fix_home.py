import re
with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update image height and border
content = content.replace('height: 120,\n                  decoration: BoxDecoration(', 'height: 130,\n                  decoration: BoxDecoration(')

# 2. Add Expanded
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

# 3. Change SizedBox(height: 12) to Spacer()
content = content.replace(
'''                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,''',
'''                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,'''
)

# 4. Close Expanded
content = content.replace(
'''                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }''',
'''                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }'''
)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
