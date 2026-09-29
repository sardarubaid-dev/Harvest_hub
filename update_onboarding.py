with open('lib/screens/common/onboarding_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# Remove static bool hasSeenOnboarding = false;
content = re.sub(r'static bool hasSeenOnboarding = false;\n', '', content)

# Change _handleSkipToGuestHome
old_skip = """void _handleSkipToGuestHome() {
    OnboardingScreen.hasSeenOnboarding = true;
    context.go('/customer');
  }"""
new_skip = """void _handleSkipToGuestHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) context.go('/customer');
  }"""
content = content.replace(old_skip, new_skip)

# Change _handleGetStartedAuth
old_auth = """void _handleGetStartedAuth() {
    OnboardingScreen.hasSeenOnboarding = true;
    context.go('/role_selection');
  }"""
new_auth = """void _handleGetStartedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) context.go('/role_selection');
  }"""
content = content.replace(old_auth, new_auth)

# Add import if not present
if "import 'package:shared_preferences/shared_preferences.dart';" not in content:
    content = "import 'package:shared_preferences/shared_preferences.dart';\n" + content

with open('lib/screens/common/onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
