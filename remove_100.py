import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace 100% on time fulfillment with Verified Partner
idx = content.find("100% On-Time Stall Fulfillment")
if idx != -1:
    content = content.replace("100% On-Time Stall Fulfillment", "Verified HarvestHub Partner")
    print("Replaced 100% on time")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
