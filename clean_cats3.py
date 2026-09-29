with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1

for i, l in enumerate(lines):
    if 'itemCount: categories.length,' in l:
        # The SizedBox starts a few lines above
        for j in range(i, i-10, -1):
            if 'SizedBox(' in lines[j]:
                start_idx = j
                break
        
        # The listview ends when we hit the end of the return Padding
        # This is a bit tricky, let's just find the end bracket of child: ListView.builder
        open_brackets = 0
        for j in range(start_idx, len(lines)):
            l2 = lines[j]
            if '(' in l2: open_brackets += l2.count('(')
            if ')' in l2: open_brackets -= l2.count(')')
            if open_brackets == 0 and j > start_idx + 2:
                end_idx = j
                break
        break

if start_idx != -1 and end_idx != -1:
    new_lines = lines[:start_idx] + ['            const SizedBox.shrink(),\n'] + lines[end_idx+1:]
    with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
        f.write(''.join(new_lines))
    print(f"Replaced from {start_idx} to {end_idx}")
else:
    print("Not found")

