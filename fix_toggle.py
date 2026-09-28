import re

file_path = 'lib/screens/customer/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_toggle = """                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Delivery'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Delivery' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping, size: 20, color: _deliveryType == 'Delivery' ? Colors.white : greyText),
                                const SizedBox(width: 8),
                                Text(
                                  'Delivery',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Delivery' ? Colors.white : greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Pickup'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Pickup' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.storefront, size: 20, color: _deliveryType == 'Pickup' ? Colors.white : greyText),
                                const SizedBox(width: 8),
                                Text(
                                  'Farm Pickup',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Pickup' ? Colors.white : greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),"""

new_toggle = """                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Delivery'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Delivery' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Icon(Icons.local_shipping, size: 18, color: _deliveryType == 'Delivery' ? Colors.white : greyText),
                                Text(
                                  'Delivery',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Delivery' ? Colors.white : greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Pickup'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Pickup' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Icon(Icons.storefront, size: 18, color: _deliveryType == 'Pickup' ? Colors.white : greyText),
                                Text(
                                  'Farm Pickup',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Pickup' ? Colors.white : greyText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),"""
content = content.replace(old_toggle, new_toggle)


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
