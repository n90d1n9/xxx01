import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_reimbursement_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_reimbursement_models.dart';
import 'employee_directory_provider.dart';

final employeeReimbursementProfileProvider = StateNotifierProvider.family<
  EmployeeReimbursementProfileNotifier,
  EmployeeReimbursementProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeReimbursementProfileNotifier(null);
  }

  return EmployeeReimbursementProfileNotifier(
    buildEmployeeReimbursementProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeExpenseDraftProvider = StateNotifierProvider.family<
  EmployeeExpenseDraftNotifier,
  EmployeeExpenseDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeExpenseDraftNotifier(null);
  }

  return EmployeeExpenseDraftNotifier(
    buildEmployeeExpenseDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeReimbursementProfileNotifier
    extends StateNotifier<EmployeeReimbursementProfile?> {
  EmployeeReimbursementProfileNotifier(super.state);

  EmployeeExpenseClaim submitDraft(EmployeeExpenseDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee reimbursement profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final allowance = profile.allowanceFor(draft.category);
    if (allowance != null && draft.amount > allowance.remainingAmount) {
      throw StateError('Claim exceeds ${allowance.label} remaining balance');
    }

    final claim = draft.toClaim(id: _nextClaimId(profile));
    state = profile.copyWith(
      claims: [claim, ...profile.claims],
      allowances: _updateAllowance(
        profile.allowances,
        draft.category,
        (item) =>
            item.copyWith(pendingAmount: item.pendingAmount + claim.amount),
      ),
    );
    return claim;
  }

  void attachReceipt(String claimId) {
    final profile = state;
    if (profile == null) return;
    final claim = _claimById(profile.claims, claimId);
    if (claim == null || !claim.canAttachReceipt) return;

    state = profile.copyWith(
      claims:
          profile.claims.map((item) {
            if (item.id != claimId) return item;
            return item.copyWith(
              receiptStatus: EmployeeExpenseReceiptStatus.attached,
            );
          }).toList(),
    );
  }

  void approveClaim(String claimId) {
    final profile = state;
    if (profile == null) return;
    final claim = _claimById(profile.claims, claimId);
    if (claim == null || !claim.canApprove) return;

    state = profile.copyWith(
      claims:
          profile.claims.map((item) {
            if (item.id != claimId) return item;
            return item.copyWith(status: EmployeeExpenseClaimStatus.approved);
          }).toList(),
    );
  }

  void reimburseClaim(String claimId) {
    final profile = state;
    if (profile == null) return;
    final claim = _claimById(profile.claims, claimId);
    if (claim == null || !claim.canReimburse) return;

    state = profile.copyWith(
      claims:
          profile.claims.map((item) {
            if (item.id != claimId) return item;
            return item.copyWith(status: EmployeeExpenseClaimStatus.reimbursed);
          }).toList(),
      allowances: _updateAllowance(
        profile.allowances,
        claim.category,
        (item) => item.copyWith(
          pendingAmount: (item.pendingAmount - claim.amount).clamp(
            0,
            item.annualLimit,
          ),
          usedAmount: item.usedAmount + claim.amount,
        ),
      ),
    );
  }

  void rejectClaim(String claimId) {
    final profile = state;
    if (profile == null) return;
    final claim = _claimById(profile.claims, claimId);
    if (claim == null || !claim.canReject) return;

    state = profile.copyWith(
      claims:
          profile.claims.map((item) {
            if (item.id != claimId) return item;
            return item.copyWith(status: EmployeeExpenseClaimStatus.rejected);
          }).toList(),
      allowances: _updateAllowance(
        profile.allowances,
        claim.category,
        (item) => item.copyWith(
          pendingAmount: (item.pendingAmount - claim.amount).clamp(
            0,
            item.annualLimit,
          ),
        ),
      ),
    );
  }

  String _nextClaimId(EmployeeReimbursementProfile profile) {
    var index = profile.claims.length + 1;
    while (true) {
      final id =
          'EEX-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.claims.any((claim) => claim.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeExpenseDraftNotifier
    extends StateNotifier<EmployeeExpenseDraft?> {
  final EmployeeExpenseDraft? _initialDraft;

  EmployeeExpenseDraftNotifier(super.state) : _initialDraft = state;

  void setCategory(EmployeeExpenseCategory value) {
    state = state?.copyWith(category: value);
  }

  void setMerchant(String value) {
    state = state?.copyWith(merchant: value);
  }

  void setAmount(double value) {
    state = state?.copyWith(amount: value);
  }

  void setIncurredOn(DateTime value) {
    state = state?.copyWith(
      incurredOn: DateTime(value.year, value.month, value.day),
    );
  }

  void setDescription(String value) {
    state = state?.copyWith(description: value);
  }

  void setReceiptAttached(bool value) {
    state = state?.copyWith(receiptAttached: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeExpenseAllowance> _updateAllowance(
  List<EmployeeExpenseAllowance> allowances,
  EmployeeExpenseCategory category,
  EmployeeExpenseAllowance Function(EmployeeExpenseAllowance allowance) update,
) {
  return allowances.map((allowance) {
    if (allowance.category != category) return allowance;
    return update(allowance);
  }).toList();
}

EmployeeExpenseClaim? _claimById(
  List<EmployeeExpenseClaim> claims,
  String claimId,
) {
  for (final claim in claims) {
    if (claim.id == claimId) return claim;
  }
  return null;
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
