import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/accounting_policy_profile.dart';
import '../repositories/accounting_policy_repository_provider.dart';
import '../services/accounting_policy_service.dart';

final accountingPolicyServiceProvider = Provider<AccountingPolicyService>((
  ref,
) {
  return const AccountingPolicyService();
});

final accountingPolicyProvider =
    StateNotifierProvider<AccountingPolicyNotifier, AccountingPolicyProfile>((
      ref,
    ) {
      return AccountingPolicyNotifier(
        repository: ref.watch(accountingPolicyRepositoryProvider),
      );
    });

final accountingPolicyReviewItemsProvider =
    Provider<List<AccountingPolicyReviewItem>>((ref) {
      return ref
          .watch(accountingPolicyServiceProvider)
          .reviewItems(ref.watch(accountingPolicyProvider));
    });

class AccountingPolicyNotifier extends StateNotifier<AccountingPolicyProfile> {
  final AccountingPolicyRepository repository;
  var _isDisposed = false;

  AccountingPolicyNotifier({required this.repository})
    : super(repository.loadProfile()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableAccountingPolicyRepository) {
      return;
    }

    try {
      await repository.hydrate();
    } catch (_) {
      return;
    }
    if (!_isDisposed) {
      state = repository.loadProfile();
    }
  }

  void updateProfile(AccountingPolicyProfile profile) {
    repository.saveProfile(profile);
    state = repository.loadProfile();
  }

  void updateEntityName(String value) {
    final normalized = value.trim();
    updateProfile(
      state.copyWith(entityName: normalized.isEmpty ? 'Kaysir' : normalized),
    );
  }

  void updateFramework(AccountingPolicyFramework framework) {
    updateProfile(state.copyWith(framework: framework));
  }

  void updateJurisdiction(String value) {
    final normalized = value.trim();
    updateProfile(
      state.copyWith(
        jurisdiction: normalized.isEmpty ? 'Indonesia' : normalized,
      ),
    );
  }

  void updateFunctionalCurrency(String value) {
    updateProfile(state.copyWith(functionalCurrency: _currency(value)));
  }

  void updatePresentationCurrency(String value) {
    updateProfile(state.copyWith(presentationCurrency: _currency(value)));
  }

  void updateCloseCadence(AccountingPolicyCloseCadence cadence) {
    updateProfile(state.copyWith(closeCadence: cadence));
  }

  void updateAccrualBasis(bool value) {
    updateProfile(state.copyWith(accrualBasis: value));
  }

  void updateRequireComparatives(bool value) {
    updateProfile(state.copyWith(requireComparatives: value));
  }

  void updatePpnRegistered(bool value) {
    updateProfile(state.copyWith(ppnRegistered: value));
  }

  void updateManagementAssertions(bool value) {
    updateProfile(state.copyWith(includeManagementAssertions: value));
  }

  String _currency(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized.isEmpty ? 'IDR' : normalized;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
