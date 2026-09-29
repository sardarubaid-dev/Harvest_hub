with open('lib/router/app_router.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add a redirect for '/' to '/customer'
old_redirect = "if (isOnboarding || state.matchedLocation == '/') return '/customer';"
new_redirect = "if (isOnboarding || state.matchedLocation == '/') return '/customer';"

if old_redirect in content:
    # already there for auth. Let's handle it for unauth too.
    content = content.replace(
        "if (uriStr.startsWith('/farmer') || uriStr.startsWith('/admin')) {",
        "if (state.matchedLocation == '/') return '/customer';\n          if (uriStr.startsWith('/farmer') || uriStr.startsWith('/admin')) {"
    )
    with open('lib/router/app_router.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added fallback redirect for '/'")
