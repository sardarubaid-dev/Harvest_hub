import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';

import 'farmer_dashboard_tab.dart';
import 'farmer_inventory_tab.dart';
import 'farmer_orders_tab.dart';
import 'farmer_profile_tab.dart';

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
        return 1;
      case 'orders':
        return 2;
      case 'profile':
        return 3;
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
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farmer Dashboard'),
          backgroundColor: Colors.amber.shade800,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 16),
              const Text('Setting up your Farmer Profile...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authProvider.logout(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          FarmerDashboardTab(),
          FarmerInventoryTab(),
          FarmerOrdersTab(),
          FarmerProfileTab(),
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
