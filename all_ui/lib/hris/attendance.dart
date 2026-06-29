import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class AttendanceRecord {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // "present", "late", "absent"

  AttendanceRecord({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
  });
}

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
  });
}

// Providers
final currentUserProvider = Provider<User>((ref) {
  return User(
    id: 'u1',
    name: 'Alex Johnson',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    role: 'Software Developer',
  );
});

final attendanceRecordsProvider =
    StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>((ref) {
      return AttendanceNotifier();
    });

final todayAttendanceProvider = Provider<AttendanceRecord?>((ref) {
  final records = ref.watch(attendanceRecordsProvider);
  final today = DateTime.now();

  return records
      .where(
        (record) =>
            record.checkInTime.year == today.year &&
            record.checkInTime.month == today.month &&
            record.checkInTime.day == today.day,
      )
      .firstOrNull;
});

final isCheckedInProvider = Provider<bool>((ref) {
  return ref.watch(todayAttendanceProvider) != null;
});

final currentTimeProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Notifiers
class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  AttendanceNotifier()
    : super([
        AttendanceRecord(
          id: 'a1',
          checkInTime: DateTime.now().subtract(
            const Duration(days: 1, hours: 1),
          ),
          checkOutTime: DateTime.now().subtract(const Duration(days: 1)),
          status: 'present',
        ),
        AttendanceRecord(
          id: 'a2',
          checkInTime: DateTime.now().subtract(
            const Duration(days: 2, hours: 2),
          ),
          checkOutTime: DateTime.now().subtract(const Duration(days: 2)),
          status: 'late',
        ),
      ]);

  void checkIn() {
    final now = DateTime.now();
    final isLate = now.hour >= 9 && now.minute > 15; // Late after 9:15 AM

    state = [
      ...state,
      AttendanceRecord(
        id: 'a${state.length + 1}',
        checkInTime: now,
        status: isLate ? 'late' : 'present',
      ),
    ];
  }

  void checkOut() {
    final todayRecord = state.lastWhere(
      (record) => _isSameDay(record.checkInTime, DateTime.now()),
      orElse: () => throw Exception('No check-in record found for today'),
    );

    state = [
      ...state.where((record) => record.id != todayRecord.id),
      AttendanceRecord(
        id: todayRecord.id,
        checkInTime: todayRecord.checkInTime,
        checkOutTime: DateTime.now(),
        status: todayRecord.status,
      ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// UI
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isCheckedIn = ref.watch(isCheckedInProvider);
    final todayRecord = ref.watch(todayAttendanceProvider);
    final attendanceHistory = ref.watch(attendanceRecordsProvider);

    // Set up a timer to update the current time every second
    ref.listen(currentTimeProvider, (previous, next) {});
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(currentTimeProvider.notifier).state = DateTime.now();
    });

    final currentTime = ref.watch(currentTimeProvider);
    final timeString = DateFormat('HH:mm:ss').format(currentTime);
    final dateString = DateFormat('EEEE, MMMM d, yyyy').format(currentTime);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top app bar with user info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(currentUser.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser.role,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Time display card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      timeString,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      dateString,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    if (todayRecord != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Checked in at ${DateFormat('HH:mm').format(todayRecord.checkInTime)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Check-in/out button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (isCheckedIn) {
                      ref.read(attendanceRecordsProvider.notifier).checkOut();
                    } else {
                      ref.read(attendanceRecordsProvider.notifier).checkIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCheckedIn ? Colors.orange : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCheckedIn ? Icons.logout : Icons.login,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Attendance history title
              const Text(
                'Attendance History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Attendance history list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: attendanceHistory.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: Colors.grey[200], height: 1),
                    itemBuilder: (context, index) {
                      final record = attendanceHistory[index];
                      final date = DateFormat(
                        'MMM d',
                      ).format(record.checkInTime);
                      final checkIn = DateFormat(
                        'HH:mm',
                      ).format(record.checkInTime);
                      final checkOut =
                          record.checkOutTime != null
                              ? DateFormat('HH:mm').format(record.checkOutTime!)
                              : '-- : --';

                      // Calculate duration if checked out
                      String duration = '--';
                      if (record.checkOutTime != null) {
                        final diff = record.checkOutTime!.difference(
                          record.checkInTime,
                        );
                        duration = '${diff.inHours}h ${diff.inMinutes % 60}m';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    record.status == 'present'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : record.status == 'late'
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  record.status == 'present'
                                      ? Icons.check_circle_outline
                                      : record.status == 'late'
                                      ? Icons.access_time
                                      : Icons.cancel_outlined,
                                  color:
                                      record.status == 'present'
                                          ? Colors.green
                                          : record.status == 'late'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  record.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        record.status == 'present'
                                            ? Colors.green
                                            : record.status == 'late'
                                            ? Colors.orange
                                            : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$checkIn - $checkOut',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Main
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AttendanceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
