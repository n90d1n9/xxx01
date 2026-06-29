// Step 4: Review & Confirmation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/user_profile_provider.dart';

class ReviewConfirmation extends ConsumerWidget {
  const ReviewConfirmation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final skills = ref.watch(skillsListProvider);
    final preferences = ref.watch(preferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.person,
                  label: 'Name',
                  value: profile?.name ?? 'N/A',
                ),
                _InfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: profile?.email ?? 'N/A',
                ),
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: profile?.phone ?? 'N/A',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (skills.isEmpty)
                  const Text('No skills added')
                else
                  ...skills.map(
                    (skill) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(skill.name)),
                          Text(
                            'Level ${skill.level}/10',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  value:
                      preferences?.notifications == true
                          ? 'Enabled'
                          : 'Disabled',
                ),
                _InfoRow(
                  icon: Icons.palette,
                  label: 'Theme',
                  value: preferences?.theme ?? 'light',
                ),
                _InfoRow(
                  icon: Icons.mail,
                  label: 'Newsletter',
                  value:
                      preferences?.newsletter == true
                          ? 'Subscribed'
                          : 'Not Subscribed',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
