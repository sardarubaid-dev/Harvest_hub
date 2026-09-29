with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# 1. Replace Avatar
avatar_pattern = r"child: ClipOval\(\n\s*child: Image\.asset\(\n\s*'assets/images/customer_avatar\.png',\n\s*fit: BoxFit\.cover,\n\s*errorBuilder: \(context, error, stackTrace\) => Container\(\n\s*color: const Color\(0xFFE8F7EA\),\n\s*child: Icon\(Icons\.person, color: primaryGreen, size: 22\),\n\s*\),\n\s*\),\n\s*\),"
avatar_replacement = """child: Container(
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),"""
content = re.sub(avatar_pattern, avatar_replacement, content)

# 2. Replace Greeting text
greeting_pattern = r"Text\(\n\s*'\$greeting, \$displayName',\n\s*style: const TextStyle\(\n\s*color: Colors\.white,\n\s*fontSize: 16,\n\s*fontWeight: FontWeight\.w700,\n\s*letterSpacing: -0\.1,\n\s*height: 1\.15,\n\s*\),\n\s*\),\n\s*const SizedBox\(height: 2\),\n\s*Text\(\n\s*'What would you buy today\?',\n\s*style: TextStyle\(\n\s*color: Colors\.white\.withOpacity\(0\.95\),\n\s*fontSize: 12\.5,\n\s*fontWeight: FontWeight\.w400,\n\s*height: 1\.15,\n\s*\),\n\s*\),"
greeting_replacement = """Text(
                                'Hi, $displayName ??',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Fresh Harvest Awaits',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),"""
content = re.sub(greeting_pattern, greeting_replacement, content)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated header")
