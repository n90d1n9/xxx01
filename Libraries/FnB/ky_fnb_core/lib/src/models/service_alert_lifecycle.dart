/// Lifecycle state for an operational service alert.
enum FnbServiceAlertLifecycleStatus {
  open,
  acknowledged,
  snoozed,
  resolved;

  String get label => switch (this) {
    FnbServiceAlertLifecycleStatus.open => 'Open',
    FnbServiceAlertLifecycleStatus.acknowledged => 'Acknowledged',
    FnbServiceAlertLifecycleStatus.snoozed => 'Snoozed',
    FnbServiceAlertLifecycleStatus.resolved => 'Resolved',
  };

  /// Stable ordering weight used when mixed alert states are sorted together.
  int get attentionWeight => switch (this) {
    FnbServiceAlertLifecycleStatus.open => 30,
    FnbServiceAlertLifecycleStatus.acknowledged => 20,
    FnbServiceAlertLifecycleStatus.snoozed => 10,
    FnbServiceAlertLifecycleStatus.resolved => 0,
  };
}

/// Operator action that transitions a service alert lifecycle.
enum FnbServiceAlertLifecycleAction {
  acknowledge,
  snooze,
  resolve,
  reopen;

  String get label => switch (this) {
    FnbServiceAlertLifecycleAction.acknowledge => 'Acknowledge',
    FnbServiceAlertLifecycleAction.snooze => 'Snooze',
    FnbServiceAlertLifecycleAction.resolve => 'Resolve',
    FnbServiceAlertLifecycleAction.reopen => 'Reopen',
  };

  FnbServiceAlertLifecycleStatus get resultingStatus => switch (this) {
    FnbServiceAlertLifecycleAction.acknowledge =>
      FnbServiceAlertLifecycleStatus.acknowledged,
    FnbServiceAlertLifecycleAction.snooze =>
      FnbServiceAlertLifecycleStatus.snoozed,
    FnbServiceAlertLifecycleAction.resolve =>
      FnbServiceAlertLifecycleStatus.resolved,
    FnbServiceAlertLifecycleAction.reopen =>
      FnbServiceAlertLifecycleStatus.open,
  };
}

/// Audit record for one lifecycle transition applied to a service alert.
class FnbServiceAlertLifecycleEvent {
  const FnbServiceAlertLifecycleEvent({
    required this.action,
    required this.status,
    required this.at,
    this.actorId,
    this.actorLabel,
    this.note,
  });

  /// Operator action that produced this lifecycle state.
  final FnbServiceAlertLifecycleAction action;

  /// Lifecycle state after the action was applied.
  final FnbServiceAlertLifecycleStatus status;

  /// Time the lifecycle transition happened.
  final DateTime at;

  /// Optional stable identifier for the operator or integration actor.
  final String? actorId;

  /// Optional display name for the operator or integration actor.
  final String? actorLabel;

  /// Optional operator note attached to this lifecycle transition.
  final String? note;

  String get actionLabel => action.label;

  String get statusLabel => status.label;

  String get actorDisplayLabel {
    final label = actorLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return actorId?.trim().isNotEmpty ?? false ? actorId!.trim() : 'System';
  }

  String? get noteLabel {
    final value = note?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}

/// Tracks ownership, visibility, and audit state for a service alert.
class FnbServiceAlertLifecycle {
  const FnbServiceAlertLifecycle({
    this.status = FnbServiceAlertLifecycleStatus.open,
    this.ownerId,
    this.ownerLabel,
    this.updatedAt,
    this.snoozedUntil,
    this.auditTrail = const [],
  }) : assert(ownerId == null || ownerId != '', 'ownerId must not be empty.'),
       assert(
         ownerLabel == null || ownerLabel != '',
         'ownerLabel must not be empty.',
       );

  /// Current lifecycle state.
  final FnbServiceAlertLifecycleStatus status;

  /// Optional stable identifier for the current owner.
  final String? ownerId;

  /// Optional display label for the current owner.
  final String? ownerLabel;

  /// Last time this lifecycle state changed.
  final DateTime? updatedAt;

  /// Time when a snoozed alert should return to attention.
  final DateTime? snoozedUntil;

  /// Ordered lifecycle events for audit and handoff history.
  final List<FnbServiceAlertLifecycleEvent> auditTrail;

  bool get isOpen => status == FnbServiceAlertLifecycleStatus.open;

  bool get isAcknowledged {
    return status == FnbServiceAlertLifecycleStatus.acknowledged;
  }

  bool get isResolved => status == FnbServiceAlertLifecycleStatus.resolved;

  bool get hasOwner {
    return (ownerId?.trim().isNotEmpty ?? false) ||
        (ownerLabel?.trim().isNotEmpty ?? false);
  }

  String get statusLabel => status.label;

  String? get ownerDisplayLabel {
    final label = ownerLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    final id = ownerId?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }

  bool isSnoozedAt(DateTime now) {
    if (status != FnbServiceAlertLifecycleStatus.snoozed) return false;
    final until = snoozedUntil;
    return until == null || until.isAfter(now);
  }

  bool isActionableAt(DateTime now) {
    return !isResolved && !isSnoozedAt(now);
  }

  String? snoozedUntilLabel() {
    final until = snoozedUntil;
    if (until == null) return null;
    return 'Snoozed until ${_twoDigits(until.hour)}:${_twoDigits(until.minute)}';
  }

  List<FnbServiceAlertLifecycleAction> availableActionsAt(DateTime now) {
    if (isResolved) return const [FnbServiceAlertLifecycleAction.reopen];
    if (isSnoozedAt(now)) {
      return const [
        FnbServiceAlertLifecycleAction.acknowledge,
        FnbServiceAlertLifecycleAction.resolve,
        FnbServiceAlertLifecycleAction.reopen,
      ];
    }
    return const [
      FnbServiceAlertLifecycleAction.acknowledge,
      FnbServiceAlertLifecycleAction.snooze,
      FnbServiceAlertLifecycleAction.resolve,
    ];
  }

  FnbServiceAlertLifecycle applyAction(
    FnbServiceAlertLifecycleAction action, {
    required DateTime at,
    Duration snoozeDuration = const Duration(minutes: 15),
    DateTime? snoozedUntil,
    String? actorId,
    String? actorLabel,
    String? ownerId,
    String? ownerLabel,
    String? note,
  }) {
    final nextStatus = action.resultingStatus;
    final nextSnoozedUntil = action == FnbServiceAlertLifecycleAction.snooze
        ? snoozedUntil ?? at.add(snoozeDuration)
        : null;
    final event = FnbServiceAlertLifecycleEvent(
      action: action,
      status: nextStatus,
      at: at,
      actorId: actorId,
      actorLabel: actorLabel,
      note: note,
    );

    return FnbServiceAlertLifecycle(
      status: nextStatus,
      updatedAt: at,
      snoozedUntil: nextSnoozedUntil,
      ownerId: ownerId ?? this.ownerId,
      ownerLabel: ownerLabel ?? this.ownerLabel,
      auditTrail: [...auditTrail, event],
    );
  }

  FnbServiceAlertLifecycle copyWith({
    FnbServiceAlertLifecycleStatus? status,
    String? ownerId,
    String? ownerLabel,
    DateTime? updatedAt,
    DateTime? snoozedUntil,
    List<FnbServiceAlertLifecycleEvent>? auditTrail,
  }) {
    return FnbServiceAlertLifecycle(
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      ownerLabel: ownerLabel ?? this.ownerLabel,
      updatedAt: updatedAt ?? this.updatedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      auditTrail: auditTrail ?? this.auditTrail,
    );
  }
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
