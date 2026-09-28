with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Fix total calculation
old_calc = '''    int totalPayable = _itemsTotal > 0
        ? _itemsTotal + 20
        : 0;'''
new_calc = '''    int totalPayable = _itemsTotal;'''
c = c.replace(old_calc, new_calc)

# Remove the Marketplace Service Fee UI row
old_fee_ui = '''                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Marketplace Service Fee',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Rs. 20',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ],
                              ),'''
new_fee_ui = ''
c = c.replace(old_fee_ui, new_fee_ui)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with cart fee fix")
