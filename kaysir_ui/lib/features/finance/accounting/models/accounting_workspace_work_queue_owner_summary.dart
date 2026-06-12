class AccountingWorkspaceWorkQueueOwnerLoad {
  const AccountingWorkspaceWorkQueueOwnerLoad({
    required this.ownerLabel,
    required this.queueCount,
    required this.totalItems,
    required this.overdueItems,
    required this.dueTodayItems,
    required this.onTrackItems,
    required this.criticalItems,
    required this.worstOverdueDays,
  });

  final String ownerLabel;
  final int queueCount;
  final int totalItems;
  final int overdueItems;
  final int dueTodayItems;
  final int onTrackItems;
  final int criticalItems;
  final int worstOverdueDays;

  int get timeSensitiveItems => overdueItems + dueTodayItems;
  bool get hasOverdueItems => overdueItems > 0;
  bool get hasDueTodayItems => dueTodayItems > 0;
  bool get hasTimeSensitiveItems => timeSensitiveItems > 0;
  bool get hasCriticalItems => criticalItems > 0;
}

class AccountingWorkspaceWorkQueueOwnerSummary {
  const AccountingWorkspaceWorkQueueOwnerSummary({required this.owners});

  final List<AccountingWorkspaceWorkQueueOwnerLoad> owners;

  int get ownerCount => owners.length;
  bool get hasOwners => owners.isNotEmpty;
  AccountingWorkspaceWorkQueueOwnerLoad? get primaryOwner {
    if (owners.isEmpty) return null;

    return owners.first;
  }
}
