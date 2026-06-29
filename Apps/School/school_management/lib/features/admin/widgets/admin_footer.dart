import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminFooter extends ConsumerWidget {
  const AdminFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '©2025 Kayys Tech. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (MediaQuery.of(context).size.width > 600) ...[
            TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
            TextButton(onPressed: () {}, child: const Text('Terms of Service')),
          ],
          IconButton(
            icon: const Icon(Icons.support_agent, size: 20),
            onPressed: () {},
            tooltip: 'Contact Support',
          ),
        ],
      ),
    );
  }
}
