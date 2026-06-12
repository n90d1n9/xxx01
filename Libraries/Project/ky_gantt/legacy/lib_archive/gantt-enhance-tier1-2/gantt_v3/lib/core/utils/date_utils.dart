import '../models/task_model.dart';

class GanttDateUtils {
  GanttDateUtils._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  static bool isWeekend(DateTime d) => d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());
  static int daysBetween(DateTime a, DateTime b) => dateOnly(b).difference(dateOnly(a)).inDays;

  static double dayOffset(DateTime start, DateTime date, double dayWidth) {
    final days = daysBetween(start, date);
    return days * dayWidth;
  }

  static double taskBarWidth(Task task, double dayWidth) {
    final days = task.durationDays;
    return (days * dayWidth).clamp(dayWidth, double.infinity);
  }

  static String durationLabel(Task task) {
    final d = task.durationDays;
    if (d < 7) return '${d}d';
    if (d < 30) return '${(d / 7).round()}w';
    return '${(d / 30).round()}mo';
  }

  static List<DateTime> daysInRange(DateTime start, DateTime end) {
    final list = <DateTime>[];
    var curr = dateOnly(start);
    final last = dateOnly(end);
    while (!curr.isAfter(last)) {
      list.add(curr);
      curr = curr.add(const Duration(days: 1));
    }
    return list;
  }

  static List<DateTime> monthsInRange(DateTime start, DateTime end) {
    final list = <DateTime>[];
    var curr = DateTime(start.year, start.month);
    final last = DateTime(end.year, end.month);
    while (!curr.isAfter(last)) {
      list.add(curr);
      curr = DateTime(curr.year, curr.month + 1);
    }
    return list;
  }

  static String formatShortDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String formatMonthShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.month - 1];
  }

  static String formatMonth(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  static String formatRelativeDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatShortDate(d);
  }

  static String weekLabel(DateTime weekStart) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekStart.day} ${months[weekStart.month - 1]}';
  }

  static String quarterLabel(DateTime d) => 'Q${((d.month - 1) ~/ 3) + 1} ${d.year}';

  static String formatDayHeader(DateTime d) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return '${days[d.weekday - 1]} ${d.day}';
  }
}
