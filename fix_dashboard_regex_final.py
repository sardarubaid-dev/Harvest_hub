import re

with open("c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart", "r", encoding="utf-8") as f:
    text = f.read()

text = re.sub(r"'Good morning,[^']+'", "'Good morning, $farmerName \\u{1F44B}'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Active in market'", "_buildStatCard('$activeProducts', 'Active in market'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Needs confirmation'", "_buildStatCard('$pendingOrders', 'Needs confirmation'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Below threshold'", "_buildStatCard('${lowStockProducts.length}', 'Below threshold'", text)
text = re.sub(r"_buildStatCard\([^,]+,\s*'Total revenue'", "_buildStatCard('Rs. ${formatter.format(totalRevenue)}', 'Total revenue'", text)
text = re.sub(r"Text\([^']*?Items'", "Text('${lowStockProducts.length} Items'", text)
text = re.sub(r"'View All[^>]+>'", "'View All (${orders.length}) >'", text)
text = re.sub(r"itemsStr = '[^']+'", "itemsStr = '${order.items.length} items'", text)
text = re.sub(r"price = 'Rs\.[^']+'", "price = 'Rs. ${order.totalAmount.toStringAsFixed(0)}'", text)
text = re.sub(r"lowStockProducts\.map[^)]+\)\.join", "lowStockProducts.map((p) => '${p.name} (${p.quantity} left)').join", text)

text = text.replace("quantityAvailable", "quantity")

with open("c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart", "w", encoding="utf-8") as f:
    f.write(text)
