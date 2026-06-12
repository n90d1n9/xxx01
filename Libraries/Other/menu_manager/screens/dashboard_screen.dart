// Sample Screen Implementations
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthService.authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${authState.userId ?? "User"}'),
            ElevatedButton(
              onPressed: () =>
                  ref.read(AuthService.authProvider.notifier).logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
