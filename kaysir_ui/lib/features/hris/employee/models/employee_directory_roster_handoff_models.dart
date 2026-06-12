import 'employee_directory_roster_publish_models.dart';

/// Delivery channel used to route a roster release to an operational team.
enum EmployeeDirectoryRosterHandoffChannel {
  payrollSystem,
  financeTask,
  hrWorkspace,
}

/// Human-readable labels for roster handoff delivery channels.
extension EmployeeDirectoryRosterHandoffChannelLabel
    on EmployeeDirectoryRosterHandoffChannel {
  String get label {
    return switch (this) {
      EmployeeDirectoryRosterHandoffChannel.payrollSystem => 'Payroll system',
      EmployeeDirectoryRosterHandoffChannel.financeTask => 'Finance task',
      EmployeeDirectoryRosterHandoffChannel.hrWorkspace => 'HR workspace',
    };
  }
}

/// Current acknowledgement state for one roster release recipient.
enum EmployeeDirectoryRosterHandoffStatus { pending, acknowledged, escalated }

/// Human-readable labels for roster handoff acknowledgement states.
extension EmployeeDirectoryRosterHandoffStatusLabel
    on EmployeeDirectoryRosterHandoffStatus {
  String get label {
    return switch (this) {
      EmployeeDirectoryRosterHandoffStatus.pending => 'Pending',
      EmployeeDirectoryRosterHandoffStatus.acknowledged => 'Acknowledged',
      EmployeeDirectoryRosterHandoffStatus.escalated => 'Escalated',
    };
  }
}

/// Operational recipient expected to acknowledge a published roster packet.
class EmployeeDirectoryRosterHandoffRecipient {
  final String id;
  final String teamName;
  final String owner;
  final EmployeeDirectoryRosterHandoffChannel channel;
  final DateTime dueAt;
  final EmployeeDirectoryRosterHandoffStatus status;
  final DateTime? lastActionAt;
  final String note;

  const EmployeeDirectoryRosterHandoffRecipient({
    required this.id,
    required this.teamName,
    required this.owner,
    required this.channel,
    required this.dueAt,
    required this.status,
    required this.note,
    this.lastActionAt,
  });

  bool get isAcknowledged {
    return status == EmployeeDirectoryRosterHandoffStatus.acknowledged;
  }

  bool get isEscalated {
    return status == EmployeeDirectoryRosterHandoffStatus.escalated;
  }

  String get statusLabel => status.label;

  EmployeeDirectoryRosterHandoffRecipient copyWith({
    String? owner,
    EmployeeDirectoryRosterHandoffStatus? status,
    DateTime? lastActionAt,
    String? note,
  }) {
    return EmployeeDirectoryRosterHandoffRecipient(
      id: id,
      teamName: teamName,
      owner: owner ?? this.owner,
      channel: channel,
      dueAt: dueAt,
      status: status ?? this.status,
      lastActionAt: lastActionAt ?? this.lastActionAt,
      note: note ?? this.note,
    );
  }
}

/// Snapshot of roster release handoff readiness for the active release packet.
class EmployeeDirectoryRosterHandoffReview {
  final EmployeeDirectoryRosterRelease? latestRelease;
  final List<EmployeeDirectoryRosterHandoffRecipient> recipients;

  const EmployeeDirectoryRosterHandoffReview({
    required this.latestRelease,
    required this.recipients,
  });

  factory EmployeeDirectoryRosterHandoffReview.fromState({
    required EmployeeDirectoryRosterRelease? latestRelease,
    required Map<String, List<EmployeeDirectoryRosterHandoffRecipient>>
    recipientsByRelease,
  }) {
    if (latestRelease == null) {
      return const EmployeeDirectoryRosterHandoffReview(
        latestRelease: null,
        recipients: [],
      );
    }

    return EmployeeDirectoryRosterHandoffReview(
      latestRelease: latestRelease,
      recipients:
          recipientsByRelease[latestRelease.id] ??
          defaultRosterHandoffRecipients(latestRelease),
    );
  }

  bool get hasRelease => latestRelease != null;

  int get acknowledgedCount {
    return recipients.where((recipient) => recipient.isAcknowledged).length;
  }

  int get escalatedCount {
    return recipients.where((recipient) => recipient.isEscalated).length;
  }

  int get openCount => recipients.length - acknowledgedCount;

  double get completionRatio {
    if (recipients.isEmpty) return 0;
    return acknowledgedCount / recipients.length;
  }

  String get statusLabel {
    if (!hasRelease) return 'No release';
    if (openCount == 0) return 'Complete';
    if (escalatedCount > 0) return 'Escalated';
    return 'Pending';
  }

  String get summaryLabel {
    final release = latestRelease;
    if (release == null) return 'No roster packet published yet.';
    if (openCount == 0) {
      return '$acknowledgedCount acknowledged for ${release.versionLabel}.';
    }
    return '$acknowledgedCount acknowledged, $openCount pending for '
        '${release.versionLabel}.';
  }
}

/// Builds the default acknowledgement recipients for a roster release packet.
List<EmployeeDirectoryRosterHandoffRecipient> defaultRosterHandoffRecipients(
  EmployeeDirectoryRosterRelease release,
) {
  return [
    EmployeeDirectoryRosterHandoffRecipient(
      id: 'payroll',
      teamName: 'Payroll Operations',
      owner: 'Payroll Lead',
      channel: EmployeeDirectoryRosterHandoffChannel.payrollSystem,
      dueAt: release.publishedAt.add(const Duration(days: 1)),
      status: EmployeeDirectoryRosterHandoffStatus.pending,
      note: 'Validate payroll sync for ${release.versionLabel}.',
    ),
    EmployeeDirectoryRosterHandoffRecipient(
      id: 'finance',
      teamName: 'Finance Control',
      owner: 'Finance Controller',
      channel: EmployeeDirectoryRosterHandoffChannel.financeTask,
      dueAt: release.publishedAt.add(const Duration(days: 1)),
      status: EmployeeDirectoryRosterHandoffStatus.pending,
      note: 'Confirm reporting totals against finance cutoff.',
    ),
    EmployeeDirectoryRosterHandoffRecipient(
      id: 'peopleOps',
      teamName: 'People Ops',
      owner: release.preparedBy,
      channel: EmployeeDirectoryRosterHandoffChannel.hrWorkspace,
      dueAt: release.publishedAt.add(const Duration(days: 2)),
      status: EmployeeDirectoryRosterHandoffStatus.pending,
      note: 'Archive release evidence and stakeholder confirmations.',
    ),
  ];
}
