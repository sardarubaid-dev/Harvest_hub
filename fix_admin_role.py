with open('lib/services/auth_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """          UserModel fallbackUser = UserModel(
            uid: uid,
            name: credential.user?.displayName?.trim().isNotEmpty == true
                ? credential.user!.displayName!
                : email.split('@').first,
            email: email.trim(),
            role: 'Customer',
            isActive: true,
          );"""

new_block = """          UserModel fallbackUser = UserModel(
            uid: uid,
            name: credential.user?.displayName?.trim().isNotEmpty == true
                ? credential.user!.displayName!
                : email.split('@').first,
            email: email.trim(),
            role: email.trim().toLowerCase() == adminEmail.toLowerCase() ? 'Admin' : 'Customer',
            isActive: true,
          );"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open('lib/services/auth_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed admin fallback role")
else:
    print("Block not found!")
