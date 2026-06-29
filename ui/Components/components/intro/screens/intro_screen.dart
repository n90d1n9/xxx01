
// Example screen implementations
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/states/auth_provider.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Your introduction widgets here
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).setFirstTimeCompleted();
              context.go('/splash');
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
