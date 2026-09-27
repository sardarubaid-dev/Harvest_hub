with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('''SizedBox(
                      height: 24,
                      child: Switch(
                        value: _isStoreOpen,
                        onChanged: (val) {
                          setState(() => _isStoreOpen = val);
                        },
                        activeColor: Color(0xFFFFFFFF),
                        activeTrackColor: Color(0xFF2E7D32),
                      ),
                    ),''', '''Switch(
                      value: _isStoreOpen,
                      onChanged: (val) {
                        setState(() => _isStoreOpen = val);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xFF2E7D32),
                    ),''')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)