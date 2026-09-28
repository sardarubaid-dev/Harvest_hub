with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import re

c = re.sub(
    r"child:\s*const\s*Text\(\s*_pickupSlots\.isNotEmpty \? _pickupSlots\.first\.date : 'TBD',",
    r"child: Text(\n_pickupSlots.isNotEmpty ? _pickupSlots.first.date : 'TBD',",
    c,
    flags=re.DOTALL
)

c = re.sub(
    r"Row\(\s*children:\s*const\s*\[\s*Icon\(\s*Icons\.person_outline,\s*size:\s*18,\s*color:\s*darkText,\s*\),\s*SizedBox\(width:\s*12\),\s*Text\(\s*'\$userName - \$userPhone',",
    r"Row(\nchildren: [\nconst Icon(\nIcons.person_outline,\nsize: 18,\ncolor: darkText,\n),\nconst SizedBox(width: 12),\nText(\n'$userName - $userPhone',",
    c,
    flags=re.DOTALL
)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
