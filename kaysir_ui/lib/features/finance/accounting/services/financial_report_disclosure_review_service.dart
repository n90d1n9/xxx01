import '../models/accounting_policy_profile.dart';
import '../models/financial_report_disclosure_review.dart';
import '../models/financial_report_pack.dart';

class FinancialReportDisclosureReviewService {
  const FinancialReportDisclosureReviewService();

  List<FinancialReportDisclosureRequirement> buildRequirements({
    required FinancialReportPack pack,
    required AccountingPolicyProfile policy,
  }) {
    final requirements = <FinancialReportDisclosureRequirement>[
      for (final note in pack.notes) _requirementForNote(note),
    ];

    if (policy.includeManagementAssertions) {
      requirements.add(_managementAssertionRequirement(policy));
    }

    if (policy.currencyTranslated) {
      requirements.add(_currencyTranslationRequirement(policy));
    }

    return requirements;
  }

  List<FinancialReportDisclosureReviewItem> buildReviewItems({
    required Iterable<FinancialReportDisclosureRequirement> requirements,
    Iterable<FinancialReportDisclosureResolution> resolutions = const [],
  }) {
    final resolutionsByRequirement = {
      for (final resolution in resolutions)
        resolution.requirementId: resolution,
    };

    return [
      for (final requirement in requirements)
        FinancialReportDisclosureReviewItem(
          requirement: requirement,
          resolution: resolutionsByRequirement[requirement.id],
        ),
    ];
  }

  int requiredCount(Iterable<FinancialReportDisclosureReviewItem> items) {
    return items
        .where(
          (item) =>
              item.priority ==
              FinancialReportDisclosureRequirementPriority.required,
        )
        .length;
  }

  int resolvedCount(Iterable<FinancialReportDisclosureReviewItem> items) {
    return items.where((item) => item.isResolved).length;
  }

  int unresolvedRequiredCount(
    Iterable<FinancialReportDisclosureReviewItem> items,
  ) {
    return items.where((item) => item.needsReview).length;
  }

  int approvedCount(Iterable<FinancialReportDisclosureReviewItem> items) {
    return items
        .where(
          (item) =>
              item.resolution?.status ==
              FinancialReportDisclosureResolutionStatus.approved,
        )
        .length;
  }

  double reviewRatio(Iterable<FinancialReportDisclosureReviewItem> items) {
    final itemList = items.toList(growable: false);
    if (itemList.isEmpty) {
      return 0;
    }
    return resolvedCount(itemList) / itemList.length;
  }

  FinancialReportDisclosureRequirement _requirementForNote(
    FinancialReportDisclosureNote note,
  ) {
    return FinancialReportDisclosureRequirement(
      id: disclosureRequirementIdFor(note),
      noteNumber: note.number,
      title: note.title,
      description: note.body,
      standardReferences: note.standardReferences,
      owner: _ownerForNote(note),
      priority: FinancialReportDisclosureRequirementPriority.required,
    );
  }

  FinancialReportDisclosureRequirement _managementAssertionRequirement(
    AccountingPolicyProfile policy,
  ) {
    return FinancialReportDisclosureRequirement(
      id: 'policy-management-assertions',
      noteNumber: 'MA',
      title: 'Management assertions',
      description:
          'Confirm management has reviewed the report pack basis, estimates, reconciliations, and known disclosure gaps before release.',
      standardReferences: [policy.standardReference, 'Close policy'],
      owner: 'Controller',
      priority: FinancialReportDisclosureRequirementPriority.required,
    );
  }

  FinancialReportDisclosureRequirement _currencyTranslationRequirement(
    AccountingPolicyProfile policy,
  ) {
    return FinancialReportDisclosureRequirement(
      id: 'policy-currency-translation',
      noteNumber: 'FX',
      title: 'Currency translation basis',
      description:
          'Document how ${policy.functionalCurrency} functional-currency balances are presented in ${policy.presentationCurrency}.',
      standardReferences: [policy.standardReference, 'PSAK 221 / IAS 21'],
      owner: 'Reporting accountant',
      priority: FinancialReportDisclosureRequirementPriority.required,
    );
  }

  String _ownerForNote(FinancialReportDisclosureNote note) {
    final text = '${note.title} ${note.body}'.toLowerCase();
    if (text.contains('tax') ||
        text.contains('pajak') ||
        text.contains('vat') ||
        text.contains('ppn')) {
      return 'Tax accountant';
    }
    if (text.contains('cash') ||
        text.contains('bank') ||
        text.contains('kas')) {
      return 'Treasury / Cash accountant';
    }
    if (text.contains('policy') || text.contains('basis')) {
      return 'Controller';
    }
    return 'Reporting accountant';
  }
}
