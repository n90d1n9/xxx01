class POSOrderSaveOutboxSyncBehavior {
  final String queueTitle;
  final String queueDescription;
  final String syncActionLabel;
  final String retryShownActionLabel;
  final String clearSentActionLabel;
  final int drainLimit;
  final bool retryFailedByDefault;
  final bool continueOnError;
  final bool autoSyncAfterCompletion;
  final int autoSyncMinWorkCount;
  final Duration autoSyncCooldown;
  final Duration stalePendingAfter;
  final Duration staleFailedAfter;

  const POSOrderSaveOutboxSyncBehavior({
    this.queueTitle = 'Order sync queue',
    this.queueDescription =
        'Completed orders are submitted in the background and stay reviewable.',
    this.syncActionLabel = 'Sync now',
    this.retryShownActionLabel = 'Retry shown',
    this.clearSentActionLabel = 'Clear synced',
    this.drainLimit = 20,
    this.retryFailedByDefault = true,
    this.continueOnError = true,
    this.autoSyncAfterCompletion = false,
    this.autoSyncMinWorkCount = 1,
    this.autoSyncCooldown = const Duration(seconds: 30),
    this.stalePendingAfter = const Duration(minutes: 10),
    this.staleFailedAfter = const Duration(minutes: 5),
  }) : assert(drainLimit > 0),
       assert(autoSyncMinWorkCount > 0);

  static const standard = POSOrderSaveOutboxSyncBehavior();

  static const quickCheckout = POSOrderSaveOutboxSyncBehavior(
    queueTitle: 'Quick sale sync queue',
    queueDescription:
        'Fast checkout syncs queued sales first and keeps failed saves visible for review.',
    syncActionLabel: 'Sync sales',
    retryShownActionLabel: 'Retry sales',
    drainLimit: 12,
    retryFailedByDefault: false,
    autoSyncAfterCompletion: true,
    autoSyncCooldown: Duration.zero,
    stalePendingAfter: Duration(minutes: 2),
    staleFailedAfter: Duration(minutes: 1),
  );

  static const assistedService = POSOrderSaveOutboxSyncBehavior(
    queueTitle: 'Service order sync queue',
    queueDescription:
        'Service handoffs sync in smaller batches and stop when a save needs attention.',
    syncActionLabel: 'Sync service orders',
    retryShownActionLabel: 'Retry service orders',
    drainLimit: 10,
    continueOnError: false,
    stalePendingAfter: Duration(minutes: 15),
    staleFailedAfter: Duration(minutes: 10),
  );

  static const ecommerce = POSOrderSaveOutboxSyncBehavior(
    queueTitle: 'Storefront sync queue',
    queueDescription:
        'Online orders sync in larger batches so fulfillment receives them quickly.',
    syncActionLabel: 'Sync storefront',
    retryShownActionLabel: 'Retry storefront',
    clearSentActionLabel: 'Clear submitted',
    drainLimit: 50,
    autoSyncAfterCompletion: true,
    autoSyncCooldown: Duration.zero,
    stalePendingAfter: Duration(minutes: 2),
    staleFailedAfter: Duration(minutes: 1),
  );

  POSOrderSaveOutboxSyncBehavior copyWith({
    String? queueTitle,
    String? queueDescription,
    String? syncActionLabel,
    String? retryShownActionLabel,
    String? clearSentActionLabel,
    int? drainLimit,
    bool? retryFailedByDefault,
    bool? continueOnError,
    bool? autoSyncAfterCompletion,
    int? autoSyncMinWorkCount,
    Duration? autoSyncCooldown,
    Duration? stalePendingAfter,
    Duration? staleFailedAfter,
  }) {
    return POSOrderSaveOutboxSyncBehavior(
      queueTitle: queueTitle ?? this.queueTitle,
      queueDescription: queueDescription ?? this.queueDescription,
      syncActionLabel: syncActionLabel ?? this.syncActionLabel,
      retryShownActionLabel:
          retryShownActionLabel ?? this.retryShownActionLabel,
      clearSentActionLabel: clearSentActionLabel ?? this.clearSentActionLabel,
      drainLimit: drainLimit ?? this.drainLimit,
      retryFailedByDefault: retryFailedByDefault ?? this.retryFailedByDefault,
      continueOnError: continueOnError ?? this.continueOnError,
      autoSyncAfterCompletion:
          autoSyncAfterCompletion ?? this.autoSyncAfterCompletion,
      autoSyncMinWorkCount: autoSyncMinWorkCount ?? this.autoSyncMinWorkCount,
      autoSyncCooldown: autoSyncCooldown ?? this.autoSyncCooldown,
      stalePendingAfter: stalePendingAfter ?? this.stalePendingAfter,
      staleFailedAfter: staleFailedAfter ?? this.staleFailedAfter,
    );
  }

  int autoSyncWorkCount({required int pendingCount, required int failedCount}) {
    return pendingCount + (retryFailedByDefault ? failedCount : 0);
  }

  bool shouldAutoSyncAfterOrderCompletion({
    required int pendingCount,
    required int failedCount,
    required DateTime now,
    DateTime? lastAutoSyncAt,
  }) {
    if (!autoSyncAfterCompletion) return false;

    final workCount = autoSyncWorkCount(
      pendingCount: pendingCount,
      failedCount: failedCount,
    );
    if (workCount < autoSyncMinWorkCount) return false;

    if (lastAutoSyncAt == null || autoSyncCooldown == Duration.zero) {
      return true;
    }

    return now.difference(lastAutoSyncAt) >= autoSyncCooldown;
  }

  List<String> get policyLabels {
    return [
      'Batch $drainLimit',
      retryFailedByDefault ? 'Retries failed' : 'Queued first',
      continueOnError ? 'Keeps syncing' : 'Stops on error',
      autoSyncAfterCompletion ? 'Auto after close' : 'Manual sync',
    ];
  }
}
