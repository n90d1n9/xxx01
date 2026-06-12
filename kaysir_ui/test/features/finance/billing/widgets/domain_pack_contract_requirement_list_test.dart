import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_requirement_list.dart';

void main() {
  testWidgets('DomainPackContractRequirementList renders requirement states', (
    tester,
  ) async {
    await _pumpList(
      tester,
      DomainPackContractRequirementList(
        requirements: [
          DomainPackContractRequirement(
            id: domainPackContractModuleReadinessId,
            label: 'Module contract',
            status: DomainPackContractStatus.satisfied,
            message: 'Commerce billing module is launch-ready.',
            details: const ['dashboard, invoices'],
          ),
          DomainPackContractRequirement(
            id: domainPackContractDiagnosticsProfileId,
            label: 'Diagnostics contract',
            status: DomainPackContractStatus.warning,
            message:
                'Commerce uses standard diagnostics without a domain-specific pack profile.',
          ),
          DomainPackContractRequirement(
            id: domainPackContractReleaseGateTargetsId,
            label: 'Release gate targets',
            status: DomainPackContractStatus.blocked,
            message:
                'Service operations has release gate lanes without diagnostics navigation targets.',
            details: const ['service-handoff'],
          ),
        ],
      ),
    );

    expect(find.text('Module contract'), findsOneWidget);
    expect(find.text('Diagnostics contract'), findsOneWidget);
    expect(find.text('Release gate targets'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Hardening'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('service-handoff'), findsOneWidget);
  });

  testWidgets('DomainPackContractRequirementList hides overflow rows', (
    tester,
  ) async {
    await _pumpList(
      tester,
      DomainPackContractRequirementList(
        maxVisibleRequirements: 1,
        requirements: [
          DomainPackContractRequirement(
            id: domainPackContractModuleReadinessId,
            label: 'Module contract',
            status: DomainPackContractStatus.satisfied,
            message: 'Ready.',
          ),
          DomainPackContractRequirement(
            id: domainPackContractDiagnosticsProfileId,
            label: 'Diagnostics contract',
            status: DomainPackContractStatus.warning,
            message: 'Needs profile.',
          ),
        ],
      ),
    );

    expect(find.text('Module contract'), findsOneWidget);
    expect(find.text('Diagnostics contract'), findsNothing);
    expect(find.text('+1 more requirement hidden'), findsOneWidget);
  });

  testWidgets('DomainPackContractRequirementList renders empty state', (
    tester,
  ) async {
    await _pumpList(
      tester,
      const DomainPackContractRequirementList(requirements: []),
    );

    expect(
      find.text('No domain-pack contract requirements are available.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpList(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 600, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
