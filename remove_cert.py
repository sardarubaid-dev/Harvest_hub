import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

idx_cert = content.find("Certified Organic Hub")
if idx_cert != -1:
    start_cert = content.rfind("Positioned(", 0, idx_cert)
    end_cert = content.find("),", content.find("Text", idx_cert))
    end_cert = content.find("),", end_cert+1)
    end_cert = content.find("),", end_cert+1)
    end_cert = content.find(",", end_cert+1)
    content = content[:start_cert] + 'const SizedBox.shrink(),' + content[end_cert+1:]
    print("Removed certified organic hub banner tag")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
