import 'package:flutter/material.dart';
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

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.currentUser;

        final bool isSplash = state.matchedLocation == '/splash';
        final bool isAuthScreen = state.matchedLocation == '/login' ||
            state.matchedLocation == '/onboarding' ||
            state.matchedLocation == '/role_selection' ||
            state.matchedLocation.startsWith('/create_account') ||
            state.matchedLocation == '/';
        final String uriStr = state.uri.toString();

        // Never hijack /splash; let SplashScreen finish playing Splash.mp4 and navigate when done
        if (isSplash) {
          return null;
        }

        if (isAuthenticated && user != null) {
          if (user.isAdmin && !uriStr.startsWith('/admin')) {
            return '/admin/dashboard';
          }
          if (user.isFarmer && !uriStr.startsWith('/farmer')) {
            return '/farmer/dashboard';
          }
          if (user.isCustomer && isAuthScreen) {
            return '/customer';
          }
        } else {
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
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/role_selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/create_account/:role',
          builder: (context, state) {
            final role = state.pathParameters['role'] ?? 'Customer';
            return CreateAccountScreen(role: role);
          },
        ),
        GoRoute(
          path: '/admin/:tab',
          builder: (context, state) {
            final tabStr = state.pathParameters['tab'] ?? 'dashboard';
            return AdminMainScreen(initialTab: tabStr);
          },
        ),
        GoRoute(
          path: '/farmer/categories',
          builder: (context, state) => const FarmerCategoriesScreen(),
        ),
        GoRoute(
          path: '/farmer/add-product',
          builder: (context, state) => const AddProductScreen(),
        ),
        GoRoute(
          path: '/farmer/market-pickup',
          builder: (context, state) => const FarmerMarketPickupScreen(),
        ),
        GoRoute(
          path: '/farmer/notifications',
          builder: (context, state) => const FarmerNotificationsScreen(),
        ),
        GoRoute(
          path: '/farmer/:tab',
          builder: (context, state) {
            final tabStr = state.pathParameters['tab'] ?? 'dashboard';
            return FarmerMainScreen(initialTab: tabStr);
          },
        ),
        GoRoute(
          path: '/customer',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CustomerHomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchFilterScreen(),
        ),
      ],
    );
  }
}
