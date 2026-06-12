import '../models/accounting_policy_profile.dart';

abstract class AccountingPolicyRepository {
  AccountingPolicyProfile loadProfile();

  void saveProfile(AccountingPolicyProfile profile);
}

abstract class HydratableAccountingPolicyRepository
    implements AccountingPolicyRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryAccountingPolicyRepository implements AccountingPolicyRepository {
  AccountingPolicyProfile _profile;

  InMemoryAccountingPolicyRepository({AccountingPolicyProfile? profile})
    : _profile = profile ?? AccountingPolicyProfiles.defaultProfile;

  @override
  AccountingPolicyProfile loadProfile() {
    return _profile;
  }

  @override
  void saveProfile(AccountingPolicyProfile profile) {
    _profile = profile;
  }
}
