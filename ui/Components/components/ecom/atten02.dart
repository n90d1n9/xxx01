import 'package:flutter/material.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  const AttendanceSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekap Absensi',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'April 2020',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 16.0),
          AttendanceSummaryItem(
            title: 'Hadir',
            count: 8,
          ),
          AttendanceSummaryItem(
            title: 'Tidak Tap Masuk',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Terlambat',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Pulang Cepat',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Sakit',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Cuti',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Mangkir',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Tidak Tap Pulang',
            count: 0,
          ),
          AttendanceSummaryItem(
            title: 'Tidak Hadir',
            count: 9,
          ),
        ],
      ),
    );
  }
}

class AttendanceSummaryItem extends StatelessWidget {
  final String title;
  final int count;

  const AttendanceSummaryItem({
    Key? key,
    required this.title,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.info_outline),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          Text(
            '$count Hari',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}