class AccountingWorkspaceWorkQueueActivityActionState {
  const AccountingWorkspaceWorkQueueActivityActionState({
    required this.queueId,
    this.ownerAcknowledged = false,
    this.evidenceReceived = false,
    this.escalationLogged = false,
  });

  factory AccountingWorkspaceWorkQueueActivityActionState.fromJson(
    Map<String, Object?> json,
  ) {
    return AccountingWorkspaceWorkQueueActivityActionState(
      queueId: _stringValue(json['queueId']).trim(),
      ownerAcknowledged: _boolValue(json['ownerAcknowledged']),
      evidenceReceived: _boolValue(json['evidenceReceived']),
      escalationLogged: _boolValue(json['escalationLogged']),
    );
  }

  final String queueId;
  final bool ownerAcknowledged;
  final bool evidenceReceived;
  final bool escalationLogged;

  int get completedActionCount {
    return [
      ownerAcknowledged,
      evidenceReceived,
      escalationLogged,
    ].where((isComplete) => isComplete).length;
  }

  bool get isComplete => completedActionCount == 3;

  bool get hasCapturedActions => completedActionCount > 0;

  String get summaryLabel {
    return '$completedActionCount/3 actions captured';
  }

  String get progressLabel {
    if (!hasCapturedActions) return 'Activity not started';
    if (isComplete) return 'Activity actions complete';

    return summaryLabel;
  }

  List<String> get capturedActionLabels {
    return [
      if (ownerAcknowledged) 'Owner acknowledged',
      if (evidenceReceived) 'Evidence received',
      if (escalationLogged) 'Escalation logged',
    ];
  }

  String get nextActionLabel {
    if (!ownerAcknowledged) return 'Acknowledge owner response';
    if (!evidenceReceived) return 'Record evidence receipt';
    if (!escalationLogged) return 'Log escalation outcome';

    return 'Activity actions complete';
  }

  String get ownerActionLabel {
    return ownerAcknowledged ? 'Owner acknowledged' : 'Acknowledge owner';
  }

  String get evidenceActionLabel {
    return evidenceReceived ? 'Evidence received' : 'Mark evidence received';
  }

  String get escalationActionLabel {
    return escalationLogged ? 'Escalation logged' : 'Log escalation';
  }

  String get auditActionBrief {
    final lines = [
      'Captured actions: $summaryLabel',
      '- Owner acknowledged: ${_yesNo(ownerAcknowledged)}',
      '- Evidence received: ${_yesNo(evidenceReceived)}',
      '- Escalation logged: ${_yesNo(escalationLogged)}',
      'Next action: $nextActionLabel',
    ];

    return lines.join('\n');
  }

  AccountingWorkspaceWorkQueueActivityActionState copyWith({
    bool? ownerAcknowledged,
    bool? evidenceReceived,
    bool? escalationLogged,
  }) {
    return AccountingWorkspaceWorkQueueActivityActionState(
      queueId: queueId,
      ownerAcknowledged: ownerAcknowledged ?? this.ownerAcknowledged,
      evidenceReceived: evidenceReceived ?? this.evidenceReceived,
      escalationLogged: escalationLogged ?? this.escalationLogged,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'queueId': queueId,
      'ownerAcknowledged': ownerAcknowledged,
      'evidenceReceived': evidenceReceived,
      'escalationLogged': escalationLogged,
    };
  }
}

bool _boolValue(Object? value) => value == true;

String _stringValue(Object? value) => value is String ? value : '';

String _yesNo(bool value) => value ? 'Yes' : 'No';
