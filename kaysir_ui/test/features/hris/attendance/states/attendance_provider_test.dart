import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/attendance/states/attendance_provider.dart';

void main() {
  test('attendance summary aggregates status and duration signals', () {
    final container = ProviderContainer(
      overrides: [
        attendanceSeedDateProvider.overrideWithValue(DateTime(2026, 5, 30, 9)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(attendanceSummaryProvider);

    expect(summary.totalRecords, 2);
    expect(summary.presentCount, 1);
    expect(summary.lateCount, 1);
    expect(summary.absentCount, 0);
    expect(summary.openCount, 0);
    expect(summary.completedCount, 2);
    expect(summary.totalMinutes, 180);
    expect(summary.averageMinutes, 90);
  });

  test('check in and checkout update today attendance state', () {
    final container = ProviderContainer(
      overrides: [
        attendanceSeedDateProvider.overrideWithValue(DateTime(2026, 5, 30, 9)),
      ],
    );
    addTearDown(container.dispose);

    final checkIn = DateTime(2026, 6, 1, 9, 20);
    final checkOut = DateTime(2026, 6, 1, 17, 45);

    container.read(currentTimeProvider.notifier).state = checkIn;
    container.read(attendanceRecordsProvider.notifier).checkIn(at: checkIn);

    expect(container.read(todayAttendanceProvider)?.status, 'late');
    expect(container.read(isCheckedInProvider), isTrue);

    container.read(currentTimeProvider.notifier).state = checkOut;
    container.read(attendanceRecordsProvider.notifier).checkOut(at: checkOut);

    final todayRecord = container.read(todayAttendanceProvider);
    expect(container.read(isCheckedInProvider), isFalse);
    expect(todayRecord?.checkOutTime, checkOut);
    expect(todayRecord?.durationMinutes, 505);
  });

  test('attendance risk summary highlights late and open records', () {
    final container = ProviderContainer(
      overrides: [
        attendanceSeedDateProvider.overrideWithValue(DateTime(2026, 5, 30, 9)),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(attendanceRecordsProvider.notifier)
        .checkIn(at: DateTime(2026, 6, 1, 8, 55));

    final risks = container.read(attendanceRiskSummaryProvider);

    expect(risks.openRecords, 1);
    expect(risks.lateRecords, 1);
    expect(risks.absentRecords, 0);
    expect(risks.longShifts, 0);
    expect(risks.completedRecords, 2);
    expect(risks.totalRisks, 2);
  });

  test('attendance seed date override drives initial history dates', () {
    final container = ProviderContainer(
      overrides: [
        attendanceSeedDateProvider.overrideWithValue(DateTime(2026, 7, 10, 9)),
      ],
    );
    addTearDown(container.dispose);

    final records = container.read(attendanceRecordsProvider);

    expect(records.first.checkInTime, DateTime(2026, 7, 9, 8));
    expect(records.first.checkOutTime, DateTime(2026, 7, 9, 9));
    expect(records[1].checkInTime, DateTime(2026, 7, 8, 7));
  });
}
