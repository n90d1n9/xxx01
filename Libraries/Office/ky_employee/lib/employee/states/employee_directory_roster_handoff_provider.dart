import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_roster_handoff_models.dart';
import '../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_publish_provider.dart';

/// Stores recipient acknowledgement state by roster release packet.
final employeeDirectoryRosterHandoffRecordsProvider = StateNotifierProvider<
  EmployeeDirectoryRosterHandoffRecordsNotifier,
  Map<String, List<EmployeeDirectoryRosterHandoffRecipient>>
>((ref) => EmployeeDirectoryRosterHandoffRecordsNotifier());

/// Summarizes handoff acknowledgement readiness for the latest roster release.
final employeeDirectoryRosterHandoffReviewProvider =
    Provider<EmployeeDirectoryRosterHandoffReview>((ref) {
      final releases = ref.watch(employeeDirectoryRosterReleasesProvider);
      final latestRelease = releases.isEmpty ? null : releases.first;

      return EmployeeDirectoryRosterHandoffReview.fromState(
        latestRelease: latestRelease,
        recipientsByRelease: ref.watch(
          employeeDirectoryRosterHandoffRecordsProvider,
        ),
      );
    });

/// Mutates roster release handoff recipient acknowledgement state.
class EmployeeDirectoryRosterHandoffRecordsNotifier
    extends
        StateNotifier<
          Map<String, List<EmployeeDirectoryRosterHandoffRecipient>>
        > {
  EmployeeDirectoryRosterHandoffRecordsNotifier() : super(const {});

  void acknowledge(
    EmployeeDirectoryRosterRelease release,
    String recipientId,
    DateTime acknowledgedAt,
  ) {
    _updateRecipient(
      release,
      recipientId,
      (recipient) => recipient.copyWith(
        status: EmployeeDirectoryRosterHandoffStatus.acknowledged,
        lastActionAt: acknowledgedAt,
        note: '${recipient.teamName} acknowledged ${release.versionLabel}.',
      ),
    );
  }

  void resend(
    EmployeeDirectoryRosterRelease release,
    String recipientId,
    DateTime sentAt,
  ) {
    _updateRecipient(
      release,
      recipientId,
      (recipient) => recipient.copyWith(
        lastActionAt: sentAt,
        note: 'Reminder sent to ${recipient.teamName}.',
      ),
    );
  }

  void escalate(
    EmployeeDirectoryRosterRelease release,
    String recipientId,
    DateTime escalatedAt,
  ) {
    _updateRecipient(
      release,
      recipientId,
      (recipient) => recipient.copyWith(
        status: EmployeeDirectoryRosterHandoffStatus.escalated,
        lastActionAt: escalatedAt,
        note: '${recipient.teamName} escalated for stakeholder follow-up.',
      ),
    );
  }

  void clearRelease(String releaseId) {
    final next = {...state}..remove(releaseId);
    state = next;
  }

  void _updateRecipient(
    EmployeeDirectoryRosterRelease release,
    String recipientId,
    EmployeeDirectoryRosterHandoffRecipient Function(
      EmployeeDirectoryRosterHandoffRecipient recipient,
    )
    update,
  ) {
    final recipients =
        state[release.id] ?? defaultRosterHandoffRecipients(release);
    state = {
      ...state,
      release.id:
          recipients.map((recipient) {
            if (recipient.id != recipientId) return recipient;
            return update(recipient);
          }).toList(),
    };
  }
}
