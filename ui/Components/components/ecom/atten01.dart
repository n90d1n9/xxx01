import 'package:flutter/material.dart';

class AttendanceWidget extends StatelessWidget {
  const AttendanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: const Icon(Icons.arrow_back),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '13:46:00',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 10,
                  ),
                  const SizedBox(width: 8),
                  const Text('GEDUNG S'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('6 MAR 2023'),
                          SizedBox(height: 8),
                          Text('6 Maret 2023'),
                          SizedBox(height: 8),
                          Text('07:52:42 WIB'),
                          SizedBox(height: 8),
                          Text('GEDUNG K'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('WFO - SN (08:00 - 16:00)'),
                          SizedBox(height: 8),
                          Text('------------------'),
                          SizedBox(height: 8),
                          Text('------------------'),
                          SizedBox(height: 8),
                          Text('------------------'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('CHECK OUT'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Data record absensi 7 hari terakhir'),
            ),
            AttendanceRecord(date: '05 MAR 2023', status: 'Libur'),
            AttendanceRecord(date: '04 MAR 2023', status: 'WFO - SB1 (08:00 - 13:00)'),
            AttendanceRecord(date: '03 MAR 2023', status: 'WFO - SN (08:00 - 16:00)'),
            AttendanceRecord(date: '02 MAR 2023', status: 'WFO - SN (08:00 - 16:00)'),
            AttendanceRecord(date: '01 MAR 2023', status: 'WFO - SN (08:00 - 16:00)'),
          ],
        ),
      ),
    );
  }
}

class AttendanceRecord extends StatelessWidget {
  final String date;
  final String status;

  const AttendanceRecord({Key? key, required this.date, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date),
            Text(status, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}