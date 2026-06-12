class AccountingWorkspaceWorkQueueSlaSummary {
  const AccountingWorkspaceWorkQueueSlaSummary({
    required this.queueCount,
    required this.overdueQueueCount,
    required this.dueTodayQueueCount,
    required this.onTrackQueueCount,
    required this.overdueItems,
    required this.dueTodayItems,
    required this.onTrackItems,
    required this.worstOverdueDays,
  });

  final int queueCount;
  final int overdueQueueCount;
  final int dueTodayQueueCount;
  final int onTrackQueueCount;
  final int overdueItems;
  final int dueTodayItems;
  final int onTrackItems;
  final int worstOverdueDays;

  int get timeSensitiveItems => overdueItems + dueTodayItems;
  bool get hasQueues => queueCount > 0;
  bool get hasOverdueItems => overdueItems > 0;
  bool get hasDueTodayItems => dueTodayItems > 0;
  bool get hasTimeSensitiveItems => timeSensitiveItems > 0;
}
