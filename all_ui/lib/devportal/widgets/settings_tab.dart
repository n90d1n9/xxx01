import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Settings', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildSettingItem(
                  context,
                  title: 'Profile',
                  icon: Icons.person_outline,
                  onTap: () {
                    // Navigate to profile settings
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Notifications',
                  icon: Icons.notifications_none,
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Security',
                  icon: Icons.security,
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Billing & Subscriptions',
                  icon: Icons.payment,
                  onTap: () {
                    // Navigate to billing settings
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer Portal Settings',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildSettingItem(
                  context,
                  title: 'API Documentation',
                  icon: Icons.description_outlined,
                  onTap: () {
                    // Navigate to API documentation settings
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Webhook Configuration',
                  icon: Icons.webhook,
                  onTap: () {
                    // Navigate to webhook settings
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Rate Limits & Quotas',
                  icon: Icons.speed,
                  onTap: () {
                    // Navigate to rate limit settings
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildSwitchSettingItem(
                  context,
                  title: 'Dark Mode',
                  icon: Icons.dark_mode,
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // Toggle theme
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Language',
                  icon: Icons.language,
                  trailing: Text('English', style: theme.textTheme.bodyMedium),
                  onTap: () {
                    // Show language selector
                  },
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'About',
                  icon: Icons.info_outline,
                  onTap: () {
                    // Show about dialog
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // Sign out
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            trailing ?? const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
