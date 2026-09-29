with open('lib/screens/common/splash_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("'assets/videos/Splash.mp4'", "'assets/Splash.mp4'")

with open('lib/screens/common/splash_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed video path")
