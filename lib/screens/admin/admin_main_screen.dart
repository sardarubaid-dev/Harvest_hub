import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_farmer_management_tab.dart';
import 'admin_order_moderation_tab.dart';
import 'admin_reports_analytics_tab.dart';

class AdminMainScreen extends StatefulWidget {
  final String initialTab;
  const AdminMainScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getTabIndexFromString(widget.initialTab);
  }

  @override
  void didUpdateWidget(AdminMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {

        _currentIndex = _getTabIndexFromString(widget.initialTab);
      });
    }
  }

  int _getTabIndexFromString(String tab) {
    switch (tab) {
      case 'dashboard': return 0;
      case 'farmers': return 1;
      case 'orders': return 2;
      case 'reports': return 3;
      default: return 0;
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AdminDashboardTab(),
          AdminFarmerManagementTab(),
          AdminOrderModerationTab(),
          AdminReportsAnalyticsTab(),
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
            label: 'Dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture_outlined), 
            activeIcon: Icon(Icons.agriculture), 
            label: 'Farmers'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined), 
            activeIcon: Icon(Icons.receipt_long), 
            label: 'Orders'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined), 
            activeIcon: Icon(Icons.bar_chart), 
            label: 'Reports'
          ),
        ],
      ),
    );
  }
}
