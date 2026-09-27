import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace empty or literal values with dart string interpolation
text = text.replace(\"'Good morning,  \u{1F44B}'\", \"'Good morning, \ \u{1F44B}'\")
text = text.replace(\"_buildStatCard('',\", \"_buildStatCard('\',\")
text = text.replace(\"_buildStatCard('',\", \"_buildStatCard('\',\") # wait, better use regex

text = re.sub(r\"_buildStatCard\('', 'Active in market'\", r\"_buildStatCard('\\', 'Active in market'\", text)
text = re.sub(r\"_buildStatCard\('', 'Needs confirmation'\", r\"_buildStatCard('\\', 'Needs confirmation'\", text)
text = re.sub(r\"_buildStatCard\('.length}', 'Below threshold'\", r\"_buildStatCard('\\', 'Below threshold'\", text)
text = re.sub(r\"_buildStatCard\('Rs. .format\(totalRevenue\)}', 'Total revenue'\", r\"_buildStatCard('Rs. \\', 'Total revenue'\", text)
text = re.sub(r\"Text\('.length} Items'\", r\"Text('\\ Items'\", text)
text = re.sub(r\"'View All \(.length\) >'\", r\"'View All (\\) >'\", text)
text = re.sub(r\"itemsStr = '.items.length} items'\", r\"itemsStr = '\\ items'\", text)
text = re.sub(r\"price = 'Rs. .totalAmount.toStringAsFixed\(0\)}'\", r\"price = 'Rs. \\'\", text)

# Fix quantity vs quantityAvailable
text = text.replace('quantityAvailable', 'quantity')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)