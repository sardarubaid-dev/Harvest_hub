import re

with open('lib/screens/customer/orders_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('.then((_) => setState(() {}));', '.then((_) {});')

# The end of the builder function
c = c.replace('''                  ],
                ),
              );
            },
          );''', '''                  ],
                ),
              ),
              );
            },
          );''')

with open('lib/screens/customer/orders_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
