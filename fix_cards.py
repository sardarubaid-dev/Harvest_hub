import re

# ------------- FIX CUSTOMER_HOME_SCREEN.DART -------------
with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We need to replace the _buildProductCard function.
# Since it's large, we'll do targeted replacements inside it.

start_idx = content.find('Widget _buildProductCard({')
end_idx = content.find('Widget _buildFarmerCard({', start_idx)

old_func = content[start_idx:end_idx]

# 1. Update image height and border
new_func = old_func.replace('height: 120,', 'height: 130,')

# 2. Add Expanded around the Padding that holds the texts
new_func = new_func.replace(
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
new_func = new_func.replace(
'''                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,''',
'''                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,'''
)

# 4. Close the Expanded widget properly before the end of the container
new_func = new_func.replace(
'''              ),
            ),
          ],
        ),
      ),
    );
  }''',
'''                ),
              ),
            ),
          ],
        ),
      ),
    );
  }'''
)

content = content.replace(old_func, new_func)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

# ------------- FIX PRODUCTS_SCREEN.DART -------------
with open('lib/screens/customer/products_screen.dart', 'r', encoding='utf-8') as f:
    p_content = f.read()

# products_screen has an inline card inside GridView.builder
start_idx = p_content.find('itemBuilder: (context, index) {')
# We need the second itemBuilder (the one for products)
start_idx = p_content.find('itemBuilder: (context, index) {', start_idx + 1)
end_idx = p_content.find('],', p_content.find('const Icon(', p_content.find('Icons.add', start_idx))) + 1000

# We will just do global replacements for the problematic parts in the file
# 1. Replace shrinkWrap container alignments
p_content = p_content.replace(
'''                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,''',
'''                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,'''
)

# 2. Image height
p_content = p_content.replace('height: 120,', 'height: 130,')

# 3. Add Expanded
p_content = p_content.replace(
'''                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [''',
'''                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: ['''
)

# 4. Spacer
p_content = p_content.replace(
'''                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,''',
'''                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,'''
)

# 5. Fix closing brackets for Expanded
# Finding where the Padding ends. It ends right after the Add to Cart GestureDetector.
# Let's replace the end structure
p_content = p_content.replace(
'''                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );''',
'''                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );'''
)

with open('lib/screens/customer/products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(p_content)

print("Done")

