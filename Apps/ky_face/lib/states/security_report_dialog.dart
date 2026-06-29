import 'package:flutter/material.dart';

import '../models/face_auth_state.dart';

class SecurityReportDialog extends StatelessWidget {
  final FaceAuthState authState;

  const SecurityReportDialog({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Security Report'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSecurityItem(
              icon: Icons.face,
              label: 'Face ID Status',
              value: authState.isSetup ? 'Configured' : 'Not Configured',
              isSecure: authState.isSetup,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.fingerprint,
              label: 'Biometric Status',
              value: authState.biometricAvailable ? 'Available' : 'Unavailable',
              isSecure: authState.biometricAvailable,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.device_unknown,
              label: 'Device Security',
              value: 'Secured',
              isSecure: true,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.history,
              label: 'Recent Attempts',
              value: '${authState.recentAttempts.length} records',
              isSecure: authState.recentAttempts
                  .where((a) => !a.success)
                  .isEmpty,
            ),
            const SizedBox(height: 16),
            if (authState.activeTemplate != null) ...[
              const Text(
                'Face Template Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Created: ${authState.activeTemplate!.createdAt}'),
              Text('Last Used: ${authState.activeTemplate!.lastUsed}'),
              Text('Usage Count: ${authState.activeTemplate!.usageCount}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSecure,
  }) {
    return Row(
      children: [
        Icon(icon, color: isSecure ? Colors.green : Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSecure ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isSecure ? Icons.check_circle : Icons.warning,
          color: isSecure ? Colors.green : Colors.orange,
        ),
      ],
    );
  }
}
