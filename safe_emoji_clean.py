with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('Zero storage transit ? Handled with clean orga...', 'Zero storage transit - Handled with clean orga...')
c = c.replace('5:30 PM ?" 6:00 PM', '5:30 PM - 6:00 PM')
c = c.replace('Recommended ? Farmer crates arrive by 5:15 PM', 'Recommended - Farmer crates arrive by 5:15 PM')
c = c.replace('6:00 PM ?" 6:30 PM', '6:00 PM - 6:30 PM')
c = c.replace('Ubaid Rehman ? +92 300 1234567', 'Ubaid Rehman - +92 300 1234567')
c = c.replace('? Rs. $totalPayable', '- Rs. $totalPayable')

# Replace the weird literal characters using regex that only matches inside strings (between quotes)
import re
def replace_garbage(match):
    return re.sub(r'[^\x00-\x7F]', '-', match.group(0))

c = re.sub(r"'[^']*'", replace_garbage, c)
c = re.sub(r'"[^"]*"', replace_garbage, c)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
