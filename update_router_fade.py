import re

with open('lib/router/app_router.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We will create a helper for fade transition
fade_helper = """
class _FadeTransitionPage extends CustomTransitionPage<void> {
  _FadeTransitionPage({required super.child, required super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        );
}
"""

if "_FadeTransitionPage" not in content:
    # insert before class AppRouter
    content = content.replace("class AppRouter {", fade_helper + "\nclass AppRouter {")

# Now replace builder: (context, state) => const X() with pageBuilder: ...
routes_to_fade = [
    ("'/onboarding'", "const OnboardingScreen()"),
    ("'/login'", "const SignInScreen()"),
    ("'/customer'", "const CustomerHomeScreen()"),
    ("'/admin/dashboard'", "const AdminMainScreen(initialTab: 'dashboard')"),
    ("'/farmer/dashboard'", "const FarmerMainScreen(initialTab: 'home')"),
]

for route_path, screen_widget in routes_to_fade:
    old_route = f"""path: {route_path},
          builder: (context, state) => {screen_widget},"""
    new_route = f"""path: {route_path},
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: {screen_widget},
          ),"""
    content = content.replace(old_route, new_route)

with open('lib/router/app_router.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated app_router with FadeTransitions")
