import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_compensation_seed_data.dart';
import '../models/employee_compensation_models.dart';
import 'employee_directory_provider.dart';

final employeeCompensationPackagesProvider = StateNotifierProvider<
  EmployeeCompensationPackagesNotifier,
  List<EmployeeCompensationPackage>
>((ref) {
  return EmployeeCompensationPackagesNotifier(
    buildEmployeeCompensationPackages(
      members: ref.read(employeeDirectoryMembersProvider),
      asOfDate: ref.read(employeeDirectoryAsOfDateProvider),
    ),
  );
});

final employeeCompensationPackageProvider =
    Provider.family<EmployeeCompensationPackage?, String>((ref, employeeId) {
      final packages = ref.watch(employeeCompensationPackagesProvider);
      for (final package in packages) {
        if (package.employeeId == employeeId) {
          return package;
        }
      }

      final members = ref.watch(employeeDirectoryMembersProvider);
      for (final member in members) {
        if (member.id == employeeId) {
          return buildEmployeeCompensationPackage(
            member,
            ref.watch(employeeDirectoryAsOfDateProvider),
          );
        }
      }
      return null;
    });

final employeeCompensationReviewDraftProvider = StateNotifierProvider.family<
  EmployeeCompensationReviewDraftNotifier,
  EmployeeCompensationReviewDraft?,
  String
>((ref, employeeId) {
  final package = ref.watch(employeeCompensationPackageProvider(employeeId));
  if (package == null) {
    return EmployeeCompensationReviewDraftNotifier(null);
  }

  return EmployeeCompensationReviewDraftNotifier(
    EmployeeCompensationReviewDraft.fromPackage(
      package: package,
      asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
    ),
  );
});

final employeeCompensationReviewRequestsProvider = StateNotifierProvider<
  EmployeeCompensationReviewRequestsNotifier,
  List<EmployeeCompensationReviewRequest>
>((ref) => EmployeeCompensationReviewRequestsNotifier());

final employeeCompensationReviewsForEmployeeProvider =
    Provider.family<List<EmployeeCompensationReviewRequest>, String>((
      ref,
      employeeId,
    ) {
      return ref
          .watch(employeeCompensationReviewRequestsProvider)
          .where((request) => request.employeeId == employeeId)
          .toList();
    });

final employeeCompensationReviewSummaryProvider =
    Provider.family<EmployeeCompensationReviewSummary, String>((
      ref,
      employeeId,
    ) {
      return EmployeeCompensationReviewSummary.fromRequests(
        ref.watch(employeeCompensationReviewsForEmployeeProvider(employeeId)),
      );
    });

class EmployeeCompensationPackagesNotifier
    extends StateNotifier<List<EmployeeCompensationPackage>> {
  EmployeeCompensationPackagesNotifier(super.state);

  void updatePackage(EmployeeCompensationPackage updatedPackage) {
    var found = false;
    final updated =
        state.map((package) {
          if (package.employeeId == updatedPackage.employeeId) {
            found = true;
            return updatedPackage;
          }
          return package;
        }).toList();

    state = found ? updated : [...state, updatedPackage];
  }
}

class EmployeeCompensationReviewDraftNotifier
    extends StateNotifier<EmployeeCompensationReviewDraft?> {
  EmployeeCompensationReviewDraftNotifier(super.state);

  void setReviewType(EmployeeCompensationReviewType value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(reviewType: value);
  }

  void setProposedBaseSalary(double value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(proposedBaseSalary: value);
  }

  void setEffectiveDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      effectiveDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setJustification(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(justification: value);
  }

  void reset() {
    final draft = state;
    if (draft == null) return;
    state = EmployeeCompensationReviewDraft.fromPackage(
      package: draft.package,
      asOfDate: draft.asOfDate,
    );
  }
}

class EmployeeCompensationReviewRequestsNotifier
    extends StateNotifier<List<EmployeeCompensationReviewRequest>> {
  EmployeeCompensationReviewRequestsNotifier() : super(const []);

  EmployeeCompensationReviewRequest submitDraft(
    EmployeeCompensationReviewDraft draft,
  ) {
    final request = draft.toRequest(id: _nextId());
    state = [request, ...state];
    return request;
  }

  void approve(String requestId) {
    state =
        state.map((request) {
          if (request.id == requestId && request.canApprove) {
            return request.copyWith(
              status: EmployeeCompensationReviewStatus.approved,
            );
          }
          return request;
        }).toList();
  }

  void markApplied(String requestId) {
    state =
        state.map((request) {
          if (request.id == requestId && request.canApply) {
            return request.copyWith(
              status: EmployeeCompensationReviewStatus.applied,
            );
          }
          return request;
        }).toList();
  }

  String _nextId() {
    return 'ECR-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}
