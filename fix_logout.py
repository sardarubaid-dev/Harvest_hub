import os

files = [
    'lib/screens/admin/admin_profile_screen.dart',
    'lib/screens/customer/profile_screen.dart',
    'lib/screens/farmer/farmer_dashboard_tab.dart',
    'lib/screens/farmer/farmer_main_screen.dart',
    'lib/screens/farmer/farmer_profile_tab.dart',
    'lib/screens/farmer/farmer_waiting_screen.dart'
]

for file in files:
    try:
        if os.path.exists(file):
            with open(file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace occurrences
            new_content = content.replace("context.pushReplacement('/')", "context.go('/login')")
            new_content = new_content.replace("context.go('/')", "context.go('/login')")
            
            if new_content != content:
                with open(file, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Fixed {file}')
    except Exception as e:
        print(f'Skipped {file} due to {e}')
