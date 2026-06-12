import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';

void main() {
  test('RegistryDiagnostics stays empty without issues', () {
    final diagnostics = RegistryDiagnostics.fromIssues(
      moduleIssues: const [],
      actionRuleIssues: const [],
    );

    expect(diagnostics.hasIssues, isFalse);
    expect(diagnostics.totalIssueCount, 0);
    expect(diagnostics.productProfileIssueCount, 0);
    expect(diagnostics.moduleIssueCount, 0);
    expect(diagnostics.actionRuleIssueCount, 0);
    expect(diagnostics.issues, isEmpty);
    expect(
      diagnostics.noticeMessage,
      'Workspace registries are ready across profiles, modules, and actions.',
    );
    expect(diagnostics.sourceSummaries.map((summary) => summary.valueLabel), [
      'Ready',
      'Ready',
      'Ready',
    ]);
    expect(diagnostics.visibleIssues(2), isEmpty);
    expect(diagnostics.hiddenIssueCount(2), 0);
  });

  test('RegistryDiagnostics normalizes mixed issues', () {
    final diagnostics = RegistryDiagnostics.fromIssues(
      productProfileIssues: const [
        ProductProfileIssue(
          type: ProductProfileIssueType.unknownSelectedProfileId,
          message: 'Unknown profile id',
        ),
      ],
      moduleIssues: const [
        ModuleIssue(
          type: ModuleIssueType.blankModuleId,
          message: 'Blank module id',
        ),
      ],
      actionRuleIssues: const [
        ActionRuleIssue(
          type: ActionRuleIssueType.invalidActionRoute,
          message: 'Invalid action route',
        ),
      ],
    );

    expect(diagnostics.hasIssues, isTrue);
    expect(diagnostics.totalIssueCount, 3);
    expect(diagnostics.productProfileIssueCount, 1);
    expect(diagnostics.moduleIssueCount, 1);
    expect(diagnostics.actionRuleIssueCount, 1);
    expect(diagnostics.noticeTitle, 'Workspace registries need review');
    expect(
      diagnostics.noticeMessage,
      '3 registry issues can affect Commerce Workspace navigation and priority actions.',
    );
    expect(diagnostics.issues.map((issue) => issue.source), [
      RegistryIssueSource.profile,
      RegistryIssueSource.module,
      RegistryIssueSource.action,
    ]);
    expect(diagnostics.issues.map((issue) => issue.index), [0, 1, 2]);
    expect(diagnostics.issues.map((issue) => issue.source.label), [
      'Profile',
      'Module',
      'Action',
    ]);
    expect(diagnostics.sourceSummaries.map((summary) => summary.label), [
      'Profiles',
      'Modules',
      'Actions',
    ]);
    expect(diagnostics.sourceSummaries.map((summary) => summary.valueLabel), [
      '1',
      '1',
      '1',
    ]);
    expect(diagnostics.visibleIssues(1).single.message, 'Unknown profile id');
    expect(diagnostics.hiddenIssueCount(1), 2);
    expect(diagnostics.hiddenIssueCount(4), 0);
  });
}
