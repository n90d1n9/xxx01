import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toRelativeDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final date = DateTime(this.year, this.month, this.day);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (date == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, yyyy').format(this);
    }
  }
}
