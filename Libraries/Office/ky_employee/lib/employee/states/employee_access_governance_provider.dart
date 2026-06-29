import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_access_governance_seed_data.dart';
import '../models/employee_access_governance_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeAccessGovernanceProfileProvider = StateNotifierProvider.family<
  EmployeeAccessGovernanceProfileNotifier,
  EmployeeAccessGovernanceProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAccessGovernanceProfileNotifier(null);
  }

  return EmployeeAccessGovernanceProfileNotifier(
    buildEmployeeAccessGovernanceProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeAccessGovernanceDraftProvider = StateNotifierProvider.family<
  EmployeeAccessGovernanceDraftNotifier,
  EmployeeAccessGovernanceDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAccessGovernanceDraftNotifier(null);
  }

  return EmployeeAccessGovernanceDraftNotifier(
    buildEmployeeAccessGovernanceDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeAccessGovernanceProfileNotifier
    extends StateNotifier<EmployeeAccessGovernanceProfile?> {
  EmployeeAccessGovernanceProfileNotifier(super.state);

  EmployeeAccessGovernanceReview submitDraft(
    EmployeeAccessGovernanceDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee access governance profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final review = draft.toReview(id: _nextReviewId(profile));
    state = profile.copyWith(reviews: [review, ...profile.reviews]);
    return review;
  }

  void approveReview(String reviewId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      reviews:
          profile.reviews.map((review) {
            if (review.id != reviewId || !review.canApprove) return review;
            return review.copyWith(
              status: EmployeeAccessGovernanceStatus.approved,
              reviewedAt: profile.asOfDate,
            );
          }).toList(),
    );
  }

  void requestRevoke(String reviewId) {
    _updateReview(reviewId, (review) {
      if (!review.canRequestRevoke) return review;
      return review.copyWith(
        status: EmployeeAccessGovernanceStatus.revokeRequested,
      );
    });
  }

  void completeRevoke(String reviewId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      reviews:
          profile.reviews.map((review) {
            if (review.id != reviewId || !review.canCompleteRevoke) {
              return review;
            }
            return review.copyWith(
              status: EmployeeAccessGovernanceStatus.revoked,
              reviewedAt: profile.asOfDate,
            );
          }).toList(),
    );
  }

  void markException(String reviewId) {
    _updateReview(reviewId, (review) {
      if (!review.canMarkException) return review;
      return review.copyWith(status: EmployeeAccessGovernanceStatus.exception);
    });
  }

  void _updateReview(
    String reviewId,
    EmployeeAccessGovernanceReview Function(
      EmployeeAccessGovernanceReview review,
    )
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      reviews:
          profile.reviews.map((review) {
            if (review.id != reviewId) return review;
            return update(review);
          }).toList(),
    );
  }

  String _nextReviewId(EmployeeAccessGovernanceProfile profile) {
    var index = profile.reviews.length + 1;
    while (true) {
      final id =
          'EAG-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.reviews.any((review) => review.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeAccessGovernanceDraftNotifier
    extends StateNotifier<EmployeeAccessGovernanceDraft?> {
  final EmployeeAccessGovernanceDraft? _initialDraft;

  EmployeeAccessGovernanceDraftNotifier(super.state) : _initialDraft = state;

  void setSystemName(String value) {
    state = state?.copyWith(systemName: value);
  }

  void setRoleName(String value) {
    state = state?.copyWith(roleName: value);
  }

  void setScope(EmployeeAccessGovernanceScope value) {
    state = state?.copyWith(scope: value);
  }

  void setRisk(EmployeeAccessGovernanceRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setReviewer(String value) {
    state = state?.copyWith(reviewer: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setBusinessJustification(String value) {
    state = state?.copyWith(businessJustification: value);
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
