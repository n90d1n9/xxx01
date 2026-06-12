String ganttActivityTimeLabel(DateTime timestamp, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final elapsed = reference.difference(timestamp);

  if (elapsed.isNegative || elapsed.inSeconds < 60) return 'Just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';

  final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final year = reference.year == timestamp.year ? '' : ', ${date.year}';

  return '${_monthNames[date.month - 1]} ${date.day}$year';
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
