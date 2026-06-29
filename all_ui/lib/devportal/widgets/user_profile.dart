import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock user data
    final user = {
      'name': 'Alex Johnson',
      'email': 'alex.johnson@example.com',
      'role': 'Developer',
      'company': 'Tech Solutions Inc.',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'joinDate': 'June 15, 2023',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user['avatar']!),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name']!,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email']!,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user['role']} at ${user['company']}',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member since ${user['joinDate']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Edit profile
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            Text('Personal Information', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildProfileField(
                    context,
                    label: 'Full Name',
                    value: user['name']!,
                    icon: Icons.person,
                  ),
                  const Divider(),
                  _buildProfileField(
                    context,
                    label: 'Email',
                    value: user['email']!,
                    icon: Icons.email,
                  ),
                  const Divider(),
                  _buildProfileField(
                    context,
                    label: 'Phone',
                    value: '+1 (555) 123-4567',
                    icon: Icons.phone,
                  ),
                  const Divider(),
                  _buildProfileField(
                    context,
                    label: 'Location',
                    value: 'San Francisco, CA',
                    icon: Icons.location_on,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Company Information
            Text('Company Information', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildProfileField(
                    context,
                    label: 'Company',
                    value: user['company']!,
                    icon: Icons.business,
                  ),
                  const Divider(),
                  _buildProfileField(
                    context,
                    label: 'Role',
                    value: user['role']!,
                    icon: Icons.work,
                  ),
                  const Divider(),
                  _buildProfileField(
                    context,
                    label: 'Department',
                    value: 'Engineering',
                    icon: Icons.groups,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Settings
            Text('Account Settings', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to change password screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notification Preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to notification settings screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language & Region'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to language settings screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Two-Factor Authentication'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Toggle 2FA
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Danger zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Actions in this section can lead to data loss and cannot be undone.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Show delete account confirmation
                      _showDeleteAccountDialog(context);
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Type "DELETE" to confirm',
                    border: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete account action
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Delete Account'),
              ),
            ],
          ),
    );
  }
}
