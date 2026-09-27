import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r\"'Good morning,[^']+'\", lambda m: \"'Good morning,  \\u{1F44B}'\", text)
text = re.sub(r\"_buildStatCard\([^,]+,\s*'Active in market'\", lambda m: \"_buildStatCard('', 'Active in market'\", text)
text = re.sub(r\"_buildStatCard\([^,]+,\s*'Needs confirmation'\", lambda m: \"_buildStatCard('', 'Needs confirmation'\", text)
text = re.sub(r\"_buildStatCard\([^,]+,\s*'Below threshold'\", lambda m: \"_buildStatCard('', 'Below threshold'\", text)
text = re.sub(r\"_buildStatCard\([^,]+,\s*'Total revenue'\", lambda m: \"_buildStatCard('Rs. ', 'Total revenue'\", text)
text = re.sub(r\"Text\([^']*?Items'\", lambda m: \"Text(' Items'\", text)
text = re.sub(r\"'View All[^>]+>'\", lambda m: \"'View All () >'\", text)
text = re.sub(r\"itemsStr = '[^']+'\", lambda m: \"itemsStr = ' items'\", text)
text = re.sub(r\"price = 'Rs\.[^']+'\", lambda m: \"price = 'Rs. '\", text)
text = re.sub(r\"lowStockProducts\.map[^)]+\)\.join\", lambda m: \"lowStockProducts.map((p) => ' ( left)').join\", text)

text = text.replace('quantityAvailable', 'quantity')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)