import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../widgets/shift_list_view.dart';
import 'empl_phone_screen.dart';

// Assume these models are already defined elsewhere

// Theme and styling
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3B82F6), // Blue primary color
    brightness: Brightness.light,
  ),
  fontFamily: 'Poppins',
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1F2937),
    ),
  ),
);

// Main screen

// Navigation sidebar (for large screens)
class NavigationSidebar extends StatelessWidget {
  final double width;

  const NavigationSidebar({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 40),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.business, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text(
                  'WorkPulse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(context, 'Dashboard', Icons.dashboard_outlined, false),
          _buildNavItem(context, 'Employees', Icons.people_outline, true),
          _buildNavItem(context, 'Shifts', Icons.access_time_outlined, false),
          _buildNavItem(context, 'Companies', Icons.business_outlined, false),
          _buildNavItem(context, 'Tenants', Icons.apartment_outlined, false),
          _buildNavItem(context, 'Users', Icons.person_outline, false),
          Spacer(),
          _buildNavItem(context, 'Settings', Icons.settings_outlined, false),
          _buildNavItem(context, 'Logout', Icons.logout_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha:0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary
                  : Color(0xFF6B7280),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary
                    : Color(0xFF6B7280),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          // Navigation logic
        },
      ),
    );
  }
}

// Navigation drawer (for medium screens)
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: NavigationSidebar(width: 280));
  }
}

// Employee list panel

// Empty detail panel

// Employee detail panel

// Shifts list view

// Entity classes (minimal implementations)

// Main app entry point
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      theme: appTheme,
      home: EmployeeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
