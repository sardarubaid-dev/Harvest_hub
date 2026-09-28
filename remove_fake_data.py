import re

with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# 1. Add user variables inside build
build_start = r'int totalPayable = _itemsTotal;'
build_vars = '''int totalPayable = _itemsTotal;
    
    final authProv = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final user = authProv.currentUser;
    final userName = user?.name?.isNotEmpty == true ? user!.name : 'Customer';
    final userPhone = user?.phone?.isNotEmpty == true ? user!.phone : 'No Phone Number';
    final currentMarket = _markets.isNotEmpty ? _markets.first : null;
'''
c = re.sub(build_start, build_vars, c)

# 2. Replace hardcoded "Today, Oct 24"
c = re.sub(
    r"'Today, Oct 24'",
    r"_pickupSlots.isNotEmpty ? _pickupSlots.first.date : 'TBD'",
    c
)

# 3. Replace the entire Available collection windows hardcoded UI with dynamic _pickupSlots list
slots_regex = r"GestureDetector\(\s*onTap:\s*\(\)\s*=>\s*setState\(\(\)\s*=>\s*_selectedSlot\s*=\s*0\),.*?const SizedBox\(height:\s*16\),"
slots_replacement = '''_pickupSlots.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: Text('No pickup slots available.', style: TextStyle(color: greyText)),
                                )
                              : Column(
                                  children: List.generate(_pickupSlots.length, (index) {
                                    final slot = _pickupSlots[index];
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedSlot = index),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _selectedSlot == index
                                              ? const Color(0xFFE8F5E9)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedSlot == index
                                                ? primaryGreen.withOpacity(0.3)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _selectedSlot == index
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: _selectedSlot == index
                                                  ? primaryGreen
                                                  : Colors.grey[300],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${slot.startTime} - ${slot.endTime}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: darkText,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    slot.isAvailable ? 'Available' : 'Full',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: greyText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                            const SizedBox(height: 8),'''
c = re.sub(slots_regex, slots_replacement, c, flags=re.DOTALL)

# 4. Replace hardcoded user info
user_regex = r"'Ubaid Rehman - \+92 300 1234567'"
user_replacement = r"'$userName - $userPhone'"
c = re.sub(user_regex, user_replacement, c)

# 5. Replace hardcoded market info
market_regex = r"const Text\(\s*'Karachi Farmers Market - Stall 14B & Hub Counter',.*?'Plot 12-C, Khayaban-e-Seher, Phase 6, DHA, Karachi',.*?color:\s*greyText,\s*\),\s*\),"
market_replacement = '''Text(
                                          currentMarket?.name ?? 'Loading Market...',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currentMarket?.address ?? 'Please wait...',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: greyText,
                                          ),
                                        ),'''
c = re.sub(market_regex, market_replacement, c, flags=re.DOTALL)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
