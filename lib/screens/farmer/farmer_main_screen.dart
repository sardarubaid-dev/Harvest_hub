import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';

import 'farmer_dashboard_tab.dart';
import 'farmer_inventory_tab.dart';
import 'farmer_orders_tab.dart';
import 'farmer_profile_tab.dart';
import 'farmer_reviews_tab.dart';
import 'approval_pending_view.dart';

class FarmerMainScreen extends StatefulWidget {
  final String initialTab;
  const FarmerMainScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getTabIndexFromString(widget.initialTab);
  }

  @override
  void didUpdateWidget(FarmerMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentIndex = _getTabIndexFromString(widget.initialTab);
      });
    }
  }

  int _getTabIndexFromString(String tab) {
    switch (tab) {
      case 'dashboard':
        return 0;
      case 'inventory':
      case 'products':
        return 1;
      case 'orders':
        return 2;
      case 'reviews':
        return 3;
      case 'profile':
        return 4;
      default:
        return 0;
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final farmer = authProvider.currentFarmer;

    if (!authProvider.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farmer Dashboard'),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Setting up your Farmer Profile...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    if (!farmer.isApproved) {
      return ApprovalPendingView(farmer: farmer);
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FarmerDashboardTab(onNavigateTab: _onTabTapped),
          const FarmerInventoryTab(),
          const FarmerOrdersTab(),
          const FarmerReviewsTab(),
          const FarmerProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
