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

        if (isAuthenticated && user != null) {
          if (user.isAdmin && !state.matchedLocation.startsWith('/admin')) return '/admin/dashboard';
          if (user.isFarmer && !state.matchedLocation.startsWith('/farmer')) return '/farmer';
          
          if (user.isCustomer) {
            // If they are a customer and they just logged in on the /login screen (modal pop),
            // return null so the modal can Navigator.pop() back to their previous screen/action.
            if (isLogin) return null;
            // Otherwise, keep them off splash/root
            if (isSplash || state.matchedLocation == '/') return '/customer';
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




