import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/shift.dart';

class ShiftsListView extends StatelessWidget {
  final List<Shift> shifts;

  const ShiftsListView({super.key, required this.shifts});

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'No shifts found for this employee',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            color: Color(0xFFF9FAFB),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getShiftStatusColor(shift.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(shift.date),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Text(
                        shift.location,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Shift status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getShiftStatusColor(
                        shift.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getShiftStatusText(shift.status),
                      style: TextStyle(
                        color: _getShiftStatusColor(shift.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getShiftStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'missed':
        return 'Missed';
      default:
        return 'Unknown';
    }
  }

  Color _getShiftStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Color(0xFF3B82F6); // Blue
      case 'in_progress':
        return Color(0xFFF59E0B); // Amber
      case 'completed':
        return Color(0xFF10B981); // Green
      case 'missed':
        return Color(0xFFEF4444); // Red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }
}
