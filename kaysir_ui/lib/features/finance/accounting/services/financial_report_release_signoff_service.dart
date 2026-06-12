import '../models/accounting_policy_profile.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_release_signoff.dart';

class FinancialReportReleaseSignOffService {
  const FinancialReportReleaseSignOffService();

  List<FinancialReportReleaseSignOffRequirement> buildRequirements({
    required FinancialReportPack pack,
    required AccountingPolicyProfile policy,
  }) {
    return [
      FinancialReportReleaseSignOffRequirement(
        id: 'prepared-by-accounting',
        role: FinancialReportReleaseSignOffRole.preparer,
        title: 'Prepared by accounting',
        description:
            'Confirm ${pack.periodLabel} statements, schedules, notes, and close evidence are prepared from the current report pack.',
        owner: 'Reporting accountant',
        reference: policy.standardReference,
      ),
      FinancialReportReleaseSignOffRequirement(
        id: 'reviewed-by-controller',
        role: FinancialReportReleaseSignOffRole.reviewer,
        title: 'Controller review',
        description:
            'Review reconciliations, material exceptions, disclosure reviews, and package integrity before release.',
        owner: 'Controller',
        reference: 'Internal control / ${policy.standardReference}',
      ),
      FinancialReportReleaseSignOffRequirement(
        id: 'approved-for-release',
        role: FinancialReportReleaseSignOffRole.approver,
        title: 'Approved for release',
        description:
            'Approve the ${pack.frameworkName} financial report pack for management, board, or statutory distribution.',
        owner: _approvalOwner(policy),
        reference: '${policy.jurisdiction} release approval',
      ),
    ];
  }

  List<FinancialReportReleaseSignOffItem> buildReviewItems({
    required Iterable<FinancialReportReleaseSignOffRequirement> requirements,
    Iterable<FinancialReportReleaseSignOffResolution> resolutions = const [],
  }) {
    final resolutionsByRequirement = {
      for (final resolution in resolutions)
        resolution.requirementId: resolution,
    };

    return [
      for (final requirement in requirements)
        FinancialReportReleaseSignOffItem(
          requirement: requirement,
          resolution: resolutionsByRequirement[requirement.id],
        ),
    ];
  }

  int signedCount(Iterable<FinancialReportReleaseSignOffItem> items) {
    return items.where((item) => item.isSigned).length;
  }

  int pendingCount(Iterable<FinancialReportReleaseSignOffItem> items) {
    return items.where((item) => item.resolution == null).length;
  }

  int returnedCount(Iterable<FinancialReportReleaseSignOffItem> items) {
    return items.where((item) => item.isReturned).length;
  }

  bool releaseReady(Iterable<FinancialReportReleaseSignOffItem> items) {
    final itemList = items.toList(growable: false);
    return itemList.isNotEmpty && itemList.every((item) => !item.blocksRelease);
  }

  double completionRatio(Iterable<FinancialReportReleaseSignOffItem> items) {
    final itemList = items.toList(growable: false);
    if (itemList.isEmpty) {
      return 0;
    }
    return signedCount(itemList) / itemList.length;
  }

  String _approvalOwner(AccountingPolicyProfile policy) {
    switch (policy.framework) {
      case AccountingPolicyFramework.sakEmkm:
        return 'Owner manager';
      case AccountingPolicyFramework.sakEntitasPrivat:
        return 'Finance lead';
      case AccountingPolicyFramework.sakIndonesia:
      case AccountingPolicyFramework.ifrs:
        return 'Finance director';
    }
  }
}
