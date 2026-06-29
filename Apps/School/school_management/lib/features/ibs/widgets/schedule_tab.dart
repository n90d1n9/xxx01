import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String schedule;
  const ScheduleTab({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final formattedStart = DateFormat('MMM d, yyyy').format(startDate!);
    final formattedEnd = DateFormat('MMM d, yyyy').format(endDate!);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Schedule',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Text(
                        '$formattedStart - $formattedEnd',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Upcoming Classes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF6200EE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ['Mon', 'Wed', 'Fri'][index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EE),
                            ),
                          ),
                          Text(
                            '${20 + index}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      'Class ${index + 1}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('10:00 AM - 11:30 AM'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
