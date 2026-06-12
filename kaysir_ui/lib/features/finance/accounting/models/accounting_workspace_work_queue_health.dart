class AccountingWorkspaceWorkQueueHealth {
  const AccountingWorkspaceWorkQueueHealth({
    required this.queueCount,
    required this.totalItems,
    required this.blockedItems,
    required this.reviewItems,
    required this.monitorItems,
  });

  final int queueCount;
  final int totalItems;
  final int blockedItems;
  final int reviewItems;
  final int monitorItems;

  bool get hasQueues => queueCount > 0;
  bool get hasBlockedItems => blockedItems > 0;
  bool get hasReviewItems => reviewItems > 0;
}
