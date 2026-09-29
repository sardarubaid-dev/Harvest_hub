with open('lib/router/app_router.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Change transition duration from 600 to 300
content = content.replace("transitionDuration: const Duration(milliseconds: 600),", "transitionDuration: const Duration(milliseconds: 300),")

with open('lib/router/app_router.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated router fade duration")
