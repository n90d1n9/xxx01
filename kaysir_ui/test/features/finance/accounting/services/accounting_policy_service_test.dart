import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_policy_service.dart';

void main() {
  group('AccountingPolicyService', () {
    const service = AccountingPolicyService();

    test('marks the default Indonesian SAK policy as ready', () {
      final items = service.reviewItems(
        AccountingPolicyProfiles.defaultProfile,
      );

      expect(service.reviewCount(AccountingPolicyProfiles.defaultProfile), 0);
      expect(items.map((item) => item.id), contains('framework'));
      expect(
        items.every(
          (item) => item.status == AccountingPolicyReviewStatus.ready,
        ),
        isTrue,
      );
    });

    test('flags cash basis, translation, comparatives, and PPN exceptions', () {
      final profile = AccountingPolicyProfiles.defaultProfile.copyWith(
        accrualBasis: false,
        functionalCurrency: 'USD',
        presentationCurrency: 'IDR',
        requireComparatives: false,
        ppnRegistered: false,
      );

      final items = service.reviewItems(profile);

      expect(service.reviewCount(profile), 4);
      expect(
        items
            .where((item) => item.status == AccountingPolicyReviewStatus.review)
            .map((item) => item.id),
        ['basis', 'currency', 'comparatives', 'tax'],
      );
    });
  });
}
