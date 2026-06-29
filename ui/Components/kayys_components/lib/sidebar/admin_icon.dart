import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminIconDrawer extends StatelessWidget {
  const AdminIconDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 5),
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () => context.go('/dashboard'),
              tooltip: 'Dashboard',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/settings'),
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
