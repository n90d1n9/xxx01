import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_evidence_matrix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test(
    'decision evidence matrix builds proof readiness from register records',
    () {
      final workspace = buildProjectDecisionsWorkspaceSummary(
        project: demoProjectPortfolio.first,
        dependencyTasks: const [],
        today: DateTime(2026, 6, 11),
      );
      final matrix = workspace.decisionEvidenceMatrixSummary;

      expect(matrix.signal, ProjectDecisionEvidenceSignal.review);
      expect(matrix.itemCount, workspace.decisionRegisterSummary.recordCount);
      expect(matrix.reviewCount, greaterThan(0));
      expect(matrix.signedOffCount, greaterThan(0));
      expect(matrix.readinessPercent, greaterThan(0));
      expect(matrix.primaryItem, isNotNull);
      expect(
        matrix.items.map((item) => item.kind),
        containsAll([
          ProjectDecisionEvidenceKind.decision,
          ProjectDecisionEvidenceKind.governanceRoute,
          ProjectDecisionEvidenceKind.risk,
          ProjectDecisionEvidenceKind.milestone,
          ProjectDecisionEvidenceKind.domain,
        ]),
      );
      expect(matrix.packText, contains('decision evidence matrix'));
      expect(matrix.packText, contains('Proof checklist:'));
    },
  );
}
