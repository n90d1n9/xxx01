import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_career_path_seed_data.dart';
import '../models/employee_career_path_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeCareerPathProfileProvider = StateNotifierProvider.family<
  EmployeeCareerPathProfileNotifier,
  EmployeeCareerPathProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeCareerPathProfileNotifier(null);
  }

  return EmployeeCareerPathProfileNotifier(
    buildEmployeeCareerPathProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeCareerMoveDraftProvider = StateNotifierProvider.family<
  EmployeeCareerMoveDraftNotifier,
  EmployeeCareerMoveDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeCareerMoveDraftNotifier(null);
  }

  return EmployeeCareerMoveDraftNotifier(
    buildEmployeeCareerMoveDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeCareerPathProfileNotifier
    extends StateNotifier<EmployeeCareerPathProfile?> {
  EmployeeCareerPathProfileNotifier(super.state);

  void setReadiness(EmployeeCareerReadiness readiness) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(path: profile.path.copyWith(readiness: readiness));
  }

  void setSuccessionCoverage(EmployeeSuccessionCoverage coverage) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      path: profile.path.copyWith(successionCoverage: coverage),
    );
  }

  void markReviewed() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      path: profile.path.copyWith(
        lastTalentReviewAt: profile.asOfDate,
        nextReviewDate: profile.asOfDate.add(const Duration(days: 90)),
      ),
    );
  }

  EmployeeCareerMoveRequest submitDraft(EmployeeCareerMoveDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee career path profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final request = draft.toRequest(id: _nextMoveId(profile));
    state = profile.copyWith(moves: [request, ...profile.moves]);
    return request;
  }

  void approveMove(String moveId) {
    _updateMove(moveId, (move) {
      if (!move.canApprove) return move;
      return move.copyWith(status: EmployeeCareerMoveStatus.approved);
    });
  }

  void activateMove(String moveId) {
    _updateMove(moveId, (move) {
      if (!move.canActivate) return move;
      return move.copyWith(status: EmployeeCareerMoveStatus.active);
    });
  }

  void completeMove(String moveId) {
    _updateMove(moveId, (move) {
      if (!move.canComplete) return move;
      return move.copyWith(status: EmployeeCareerMoveStatus.completed);
    });
  }

  void declineMove(String moveId) {
    _updateMove(moveId, (move) {
      if (!move.canDecline) return move;
      return move.copyWith(status: EmployeeCareerMoveStatus.declined);
    });
  }

  void _updateMove(
    String moveId,
    EmployeeCareerMoveRequest Function(EmployeeCareerMoveRequest move) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      moves:
          profile.moves.map((move) {
            if (move.id != moveId) return move;
            return update(move);
          }).toList(),
    );
  }

  String _nextMoveId(EmployeeCareerPathProfile profile) {
    var index = profile.moves.length + 1;
    while (true) {
      final id =
          'ECP-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.moves.any((move) => move.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeCareerMoveDraftNotifier
    extends StateNotifier<EmployeeCareerMoveDraft?> {
  final EmployeeCareerMoveDraft? _initialDraft;

  EmployeeCareerMoveDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeCareerMoveType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setSponsor(String value) {
    state = state?.copyWith(sponsor: value);
  }

  void setTargetRole(String value) {
    state = state?.copyWith(targetRole: value);
  }

  void setTargetDate(DateTime value) {
    state = state?.copyWith(targetDate: _dateOnly(value));
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
