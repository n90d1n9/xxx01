class AccountingWorkspaceWorkQueueResolutionState {
  const AccountingWorkspaceWorkQueueResolutionState({
    required this.queueId,
    this.cleared = false,
  });

  factory AccountingWorkspaceWorkQueueResolutionState.fromJson(
    Map<String, Object?> json,
  ) {
    return AccountingWorkspaceWorkQueueResolutionState(
      queueId: _stringValue(json['queueId']).trim(),
      cleared: json['cleared'] == true,
    );
  }

  final String queueId;
  final bool cleared;

  bool get hasResolution => cleared;

  String get statusLabel => cleared ? 'Cleared' : 'Open';

  String get detailLabel {
    if (cleared) return 'Queue has been cleared for close tracking';

    return 'Queue is still open';
  }

  String get resolutionBrief {
    return [
      'Queue resolution: $statusLabel',
      'Detail: $detailLabel',
    ].join('\n');
  }

  AccountingWorkspaceWorkQueueResolutionState copyWith({bool? cleared}) {
    return AccountingWorkspaceWorkQueueResolutionState(
      queueId: queueId,
      cleared: cleared ?? this.cleared,
    );
  }

  Map<String, Object?> toJson() {
    return {'queueId': queueId, 'cleared': cleared};
  }
}

String _stringValue(Object? value) => value is String ? value : '';
