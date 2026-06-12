import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/ess_provider.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(employee.imageUrl!),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildTextField(
            label: 'Full Name',
            initialValue: employee.name,
            prefixIcon: Icons.person_outline,
          ),
          _buildTextField(
            label: 'Email',
            initialValue: employee.email!,
            prefixIcon: Icons.email_outlined,
          ),
          _buildTextField(
            label: 'Department',
            initialValue: employee.department!,
            prefixIcon: Icons.business_outlined,
            enabled: false,
          ),
          _buildTextField(
            label: 'Position',
            initialValue: employee.position!,
            prefixIcon: Icons.work_outline,
            enabled: false,
          ),
          _buildTextField(
            label: 'Phone Number',
            initialValue: '+1 (555) 123-4567',
            prefixIcon: Icons.phone_outlined,
          ),
          _buildTextField(
            label: 'Address',
            initialValue: '123 Main St, Anytown, ST 12345',
            prefixIcon: Icons.home_outlined,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData prefixIcon,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: Colors.indigo),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
    );
  }
}
