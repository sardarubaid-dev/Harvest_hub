with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('style: ElevatedButton.styleFrom(', 'style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40), ')
text = text.replace('style: OutlinedButton.styleFrom(', 'style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), ')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)