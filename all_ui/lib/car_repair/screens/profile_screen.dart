import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.person, size: 40, color: Colors.blue[800]),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since Jan 2022',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Profile sections
          _buildProfileSection('Account', [
            _buildProfileItem('Personal Information', Icons.person_outline),
            _buildProfileItem('Payment Methods', Icons.credit_card),
            _buildProfileItem('Notifications', Icons.notifications_none),
            _buildProfileItem('Privacy Settings', Icons.lock_outline),
          ]),
          const SizedBox(height: 24),
          _buildProfileSection('App', [
            _buildProfileItem('Language', Icons.language),
            _buildProfileItem('Appearance', Icons.palette_outlined),
            _buildProfileItem('Help & Support', Icons.help_outline),
            _buildProfileItem('About', Icons.info_outline),
          ]),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Log out
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildProfileItem(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to the respective settings page
        },
      ),
    );
  }
}
