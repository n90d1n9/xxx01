import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_activity_time_service.dart';

void main() {
  test('gantt activity time label summarizes recent activity', () {
    final now = DateTime(2026, 5, 2, 12);

    expect(
      ganttActivityTimeLabel(DateTime(2026, 5, 2, 11, 59, 20), now: now),
      'Just now',
    );
    expect(
      ganttActivityTimeLabel(DateTime(2026, 5, 2, 11, 48), now: now),
      '12m ago',
    );
    expect(ganttActivityTimeLabel(DateTime(2026, 5, 2, 9), now: now), '3h ago');
    expect(ganttActivityTimeLabel(DateTime(2026, 5, 1, 8), now: now), '1d ago');
    expect(ganttActivityTimeLabel(DateTime(2026, 4, 20), now: now), 'Apr 20');
    expect(
      ganttActivityTimeLabel(DateTime(2025, 12, 30), now: now),
      'Dec 30, 2025',
    );
    expect(
      ganttActivityTimeLabel(DateTime(2026, 5, 2, 12, 1), now: now),
      'Just now',
    );
  });
}
