import 'package:flutter/material.dart';

import '../screens/acc_payable/acc_payable_large.dart';
import '../screens/acc_payable/vendor_manage_screen.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for large screens
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1200,
            minExtendedWidth: 180,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Vendors'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description),
                label: Text('Invoices'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.paid),
                label: Text('Payments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          // Main content area
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AccountsPayableDashboard();
      case 1:
        return const VendorManagementScreen();
      case 2:
        return const AccountsPayableDashboard(); // We'll keep using the same screen for now
      default:
        return Center(
          child: Text('Screen $_selectedIndex not implemented yet'),
        );
    }
  }
}
