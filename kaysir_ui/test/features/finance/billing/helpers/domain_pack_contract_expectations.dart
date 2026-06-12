import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';

/// Test-kit helper that asserts a billing domain-pack has no release blockers.
void expectDomainPackContractReleaseReady(
  DomainPackContractReport report, {
  String? reason,
}) {
  expect(
    report.blockedRequirements,
    isEmpty,
    reason: reason ?? report.summaryLabel,
  );
}

/// Test-kit helper that asserts every billing domain-pack contract is closed.
void expectDomainPackContractFullySpecified(
  DomainPackContractReport report, {
  String? reason,
}) {
  expect(
    report.openRequirements,
    isEmpty,
    reason: reason ?? report.summaryLabel,
  );
}
