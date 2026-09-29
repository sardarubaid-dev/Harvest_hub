with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# 1. Fix Avatar background and weird shape
# The avatar was:
# child: Container(
#   color: Colors.white,
#   child: Center(
avatar_pattern = r"child: Container\(\n\s*color: Colors\.white,\n\s*child: Center\("
avatar_replacement = """child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center("""
content = re.sub(avatar_pattern, avatar_replacement, content)


# 2. Fix greeting '??' (waving hand emoji caused it)
# Text( 'Hi, $displayName ??',
greeting_pattern = r"Text\(\n\s*'Hi, \$displayName \?\?',\n\s*style: TextStyle\("
greeting_pattern2 = r"Text\(\n\s*'Hi, \$displayName ??',\n\s*style: TextStyle\("

content = re.sub(greeting_pattern, "Text('Hi, $displayName', style: TextStyle(", content)
content = re.sub(greeting_pattern2, "Text('Hi, $displayName', style: TextStyle(", content)

# 3. Fix category cards height and image size
# height: 120
content = re.sub(r"height: 120,\n\s*child: ListView\.builder\(", "height: 96,\n          child: ListView.builder(", content)

# width: 76
content = re.sub(r"child: Container\(\n\s*width: 76,\n\s*decoration: BoxDecoration\(", "child: Container(\n                    width: 80,\n                    decoration: BoxDecoration(", content)

# mainAxisAlignment: MainAxisAlignment.spaceBetween
content = re.sub(r"mainAxisAlignment: MainAxisAlignment\.spaceBetween,\n\s*children: \[", "mainAxisAlignment: MainAxisAlignment.center,\n                      children: [", content)

# Image size and quality
image_pattern = r"SizedBox\(\n\s*width: 48,\n\s*height: 48,\n\s*child: Image\.asset\(\n\s*cat\['asset'\] as String,\n\s*fit: BoxFit\.contain,\n\s*\),\n\s*\),"
image_replacement = """SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            cat['asset'] as String,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        const SizedBox(height: 4),"""
content = re.sub(image_pattern, image_replacement, content)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Applied fixes")
