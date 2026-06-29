import 'package:flutter/material.dart';

import '../models/auth_attempt.dart';

class AuthHistoryDialog extends StatelessWidget {
  final List<AuthAttempt> attempts;

  const AuthHistoryDialog({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentication History'),
      content: SizedBox(
        width: double.maxFinite,
        child: attempts.isEmpty
            ? const Center(child: Text('No authentication attempts recorded'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: attempts.length,
                itemBuilder: (context, index) {
                  final attempt = attempts[index];
                  return _buildAttemptItem(attempt);
                },
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

  Widget _buildAttemptItem(AuthAttempt attempt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: attempt.success ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: attempt.success
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                attempt.success ? Icons.check_circle : Icons.error,
                color: attempt.success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                attempt.method.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: attempt.success ? Colors.green : Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                '${attempt.timestamp.hour}:${attempt.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            attempt.timestamp.toLocal().toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (attempt.failureReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: ${attempt.failureReason}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
