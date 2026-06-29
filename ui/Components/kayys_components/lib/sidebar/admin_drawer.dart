import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final void Function()? onTap;
  const AdminDrawer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                //Image.asset('assets/logo.png', height: 60),
                Text('Admin Dashboard'),
              ],
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
