import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'customer_login_screen.dart';
import '../customer/customer_home_screen.dart';
import '../farmer/farmer_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text(
                "Loading HarvestHub...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const CustomerLoginScreen();
    }

    final user = authProvider.currentUser;
    if (user == null) {
      return const CustomerLoginScreen();
    }

    if (user.isAdmin) {
      return const AdminDashboardScreen();
    } else if (user.isFarmer) {
      return const FarmerDashboardScreen();
    } else {
      return const CustomerHomeScreen();
    }
  }
}
