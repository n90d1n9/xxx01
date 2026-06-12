import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/repositories/accounting_policy_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_accounting_policy_repository.dart';

void main() {
  group('AccountingPolicyRepository', () {
    test('in-memory repository saves and loads the current profile', () {
      final repository = InMemoryAccountingPolicyRepository();
      final profile = AccountingPolicyProfiles.defaultProfile.copyWith(
        framework: AccountingPolicyFramework.sakEmkm,
        presentationCurrency: 'USD',
      );

      repository.saveProfile(profile);

      expect(
        repository.loadProfile().framework,
        AccountingPolicyFramework.sakEmkm,
      );
      expect(repository.loadProfile().presentationCurrency, 'USD');
    });

    test('local repository hydrates a stored policy profile', () async {
      final store = _MemoryAccountingPolicyStore({
        'schemaVersion': 1,
        'profile':
            AccountingPolicyProfiles.defaultProfile
                .copyWith(entityName: 'PT Kayys Retail')
                .toJson(),
      });
      final repository = LocalAccountingPolicyRepository(store: store);

      await repository.hydrate();

      expect(repository.loadProfile().entityName, 'PT Kayys Retail');
    });

    test('local repository persists policy updates', () async {
      final store = _MemoryAccountingPolicyStore();
      final repository = LocalAccountingPolicyRepository(store: store);
      final profile = AccountingPolicyProfiles.defaultProfile.copyWith(
        framework: AccountingPolicyFramework.ifrs,
        jurisdiction: 'Indonesia / Group',
      );

      repository.saveProfile(profile);
      await repository.persist();

      final persistedProfile = AccountingPolicyProfile.fromJson(
        Map<String, dynamic>.from(store.snapshot!['profile'] as Map),
      );
      expect(persistedProfile.framework, AccountingPolicyFramework.ifrs);
      expect(persistedProfile.jurisdiction, 'Indonesia / Group');
    });
  });
}

class _MemoryAccountingPolicyStore implements AccountingPolicySnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemoryAccountingPolicyStore([this.snapshot]);

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}
