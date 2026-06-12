import '../models/accounting_policy_profile.dart';

class AccountingPolicyService {
  const AccountingPolicyService();

  List<AccountingPolicyReviewItem> reviewItems(
    AccountingPolicyProfile profile,
  ) {
    return [
      AccountingPolicyReviewItem(
        id: 'framework',
        title: 'Reporting framework',
        description:
            '${profile.framework.label} is selected for ${profile.jurisdiction}.',
        reference: profile.standardReference,
        status: AccountingPolicyReviewStatus.ready,
      ),
      AccountingPolicyReviewItem(
        id: 'basis',
        title: 'Measurement basis',
        description:
            profile.accrualBasis
                ? 'Accrual basis is enabled for revenue, expense, asset, and liability recognition.'
                : 'Cash basis is selected. Review statutory suitability before issuing reports.',
        reference: profile.standardReference,
        status:
            profile.accrualBasis
                ? AccountingPolicyReviewStatus.ready
                : AccountingPolicyReviewStatus.review,
      ),
      AccountingPolicyReviewItem(
        id: 'currency',
        title: 'Currency policy',
        description:
            profile.currencyTranslated
                ? 'Functional ${profile.functionalCurrency} is presented in ${profile.presentationCurrency}; translation review is required.'
                : 'Functional and presentation currency are both ${profile.presentationCurrency}.',
        reference: profile.standardReference,
        status:
            profile.currencyTranslated
                ? AccountingPolicyReviewStatus.review
                : AccountingPolicyReviewStatus.ready,
      ),
      AccountingPolicyReviewItem(
        id: 'comparatives',
        title: 'Comparative reporting',
        description:
            profile.requireComparatives
                ? 'Comparative columns are expected for complete financial statements.'
                : 'Comparatives are disabled. Use only when the selected framework and filing context allow it.',
        reference: profile.standardReference,
        status:
            profile.requireComparatives
                ? AccountingPolicyReviewStatus.ready
                : AccountingPolicyReviewStatus.review,
      ),
      AccountingPolicyReviewItem(
        id: 'tax',
        title: 'Indonesia tax bridge',
        description:
            profile.ppnRegistered
                ? 'PPN settlement and income-tax bridge checks stay in the close pack.'
                : 'PPN is disabled; confirm entity registration status before finalizing reports.',
        reference: 'PSAK 212 / Indonesia Tax',
        status:
            profile.ppnRegistered
                ? AccountingPolicyReviewStatus.ready
                : AccountingPolicyReviewStatus.review,
      ),
      AccountingPolicyReviewItem(
        id: 'close-cadence',
        title: 'Close cadence',
        description:
            '${profile.closeCadence.label} close cadence is configured for workflow scheduling and review discipline.',
        reference: 'Close policy',
        status: AccountingPolicyReviewStatus.ready,
      ),
    ];
  }

  int reviewCount(AccountingPolicyProfile profile) {
    return reviewItems(profile)
        .where((item) => item.status == AccountingPolicyReviewStatus.review)
        .length;
  }
}
