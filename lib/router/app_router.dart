import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/common/splash_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/farmer/farmer_dashboard_screen.dart';
import '../screens/customer/customer_home_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.currentUser;
        
        final bool isSplash = state.matchedLocation == '/splash';
        final bool isLogin = state.matchedLocation == '/login';

// Guest mode is allowed, no forced redirect to /login

        // If authenticated and trying to access splash, login or root, redirect to role dashboard
        if (isSplash || isLogin || state.matchedLocation == '/') {
          if (user != null) {
            if (user.isAdmin) return '/admin/dashboard';
            if (user.isFarmer) return '/farmer';
            return '/customer';
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
          path: '/login',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/admin/:tab',
          builder: (context, state) {
            final tabStr = state.pathParameters['tab'] ?? 'dashboard';
            return AdminDashboardScreen(initialTab: tabStr);
          },
        ),
        GoRoute(
          path: '/farmer',
          builder: (context, state) => const FarmerDashboardScreen(),
        ),
        GoRoute(
          path: '/customer',
          builder: (context, state) => const CustomerHomeScreen(),
        ),
      ],
    );
  }
}



