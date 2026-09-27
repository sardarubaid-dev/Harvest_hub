import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r"'Good morning, \s*👋'", r"'Good morning, \ 👋'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Active in market'", r"_buildStatCard('\', 'Active in market'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Needs confirmation'", r"_buildStatCard('\', 'Needs confirmation'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Below threshold'", r"_buildStatCard('\', 'Below threshold'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Total revenue'", r"_buildStatCard('Rs. \', 'Total revenue'", text)
text = re.sub(r"Text\([^,]*?Items'", r"Text('\ Items'", text)
text = re.sub(r"'View All[^>]+>'", r"'View All (\) >'", text)
text = re.sub(r"itemsStr = '[^']+'", r"itemsStr = '\ items'", text)
text = re.sub(r"price = 'Rs\.[^']+'", r"price = 'Rs. \'", text)
text = text.replace('quantityAvailable', 'quantity')
text = text.replace('lowStockProducts.map((p) => \' ( left)\')', 'lowStockProducts.map((p) => \\'\\ (\\ left)\\')')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)