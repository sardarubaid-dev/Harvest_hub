import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest_hub/screens/auth/create_account_screen.dart';
import 'package:harvest_hub/screens/role_selection_screen.dart';

import '../providers/auth_provider.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/onboarding_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/farmer/farmer_main_screen.dart';
import '../screens/farmer/farmer_categories_screen.dart';
import '../screens/farmer/add_product_screen.dart';
import '../screens/farmer/farmer_market_pickup_screen.dart';
import '../screens/farmer/farmer_notifications_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/search_filter_screen.dart';


class _FadeTransitionPage extends CustomTransitionPage<void> {
  _FadeTransitionPage({required super.child, required super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.currentUser;

        final bool isSplash = state.matchedLocation == '/splash';
        final bool isOnboarding = state.matchedLocation == '/onboarding';
        final bool isLogin = state.matchedLocation == '/login';
        final String uriStr = state.uri.toString();

        if (isSplash) {
          return null;
        }

        if (isAuthenticated && user != null) {
          if (user.isAdmin && !uriStr.startsWith('/admin')) return '/admin/dashboard';
          if (user.isFarmer && !uriStr.startsWith('/farmer')) return '/farmer/dashboard';
          
          if (user.isCustomer) {
            if (isLogin) return null;
            if (isOnboarding || state.matchedLocation == '/') return '/customer';
          }
        } else {
          if (state.matchedLocation == '/') return '/customer';
          if (uriStr.startsWith('/farmer') || uriStr.startsWith('/admin')) {
            return '/login';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/role_selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: const SignInScreen(),
          ),
        ),
        GoRoute(
          path: '/create_account',
          builder: (context, state) => const CreateAccountScreen(role: 'customer'),
        ),
        GoRoute(
          path: '/customer',
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: const CustomerHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/customer/search',
          builder: (context, state) => const SearchFilterScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: const AdminMainScreen(initialTab: 'dashboard'),
          ),
        ),
        GoRoute(
          path: '/farmer/dashboard',
          pageBuilder: (context, state) => _FadeTransitionPage(
            key: state.pageKey,
            child: const FarmerMainScreen(initialTab: 'home'),
          ),
        ),
        GoRoute(
          path: '/farmer/categories',
          builder: (context, state) => const FarmerCategoriesScreen(),
        ),
        GoRoute(
          path: '/farmer/add_product',
          builder: (context, state) => const AddProductScreen(),
        ),
        GoRoute(
          path: '/farmer/market_pickup',
          builder: (context, state) => const FarmerMarketPickupScreen(),
        ),
        GoRoute(
          path: '/farmer/notifications',
          builder: (context, state) => const FarmerNotificationsScreen(),
        ),
      ],
    );
  }
}
