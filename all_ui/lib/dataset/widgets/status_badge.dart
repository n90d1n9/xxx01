import 'package:flutter/material.dart';

import '../models/job_status.dart';

class StatusBadge extends StatelessWidget {
  final JobStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.draft:
        return Colors.grey;
      case JobStatus.queued:
        return Colors.orange;
      case JobStatus.training:
        return Colors.blue;
      case JobStatus.evaluating:
        return Colors.purple;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.failed:
        return Colors.red;
      case JobStatus.cancelled:
        return Colors.grey;
      case JobStatus.deployed:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
