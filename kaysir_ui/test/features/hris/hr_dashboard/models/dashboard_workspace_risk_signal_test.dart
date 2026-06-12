import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace risk signal map indexes rollup items by workspace id', () {
    final rollup = DashboardRiskRollup(
      items: [
        DashboardRiskItem(
          workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
          totalRisks: 8,
          timeSensitiveRisks: 2,
          leadingSignal: '2 blocked onboarding',
        ),
      ],
    );

    final signals = buildDashboardWorkspaceRiskSignalMap(rollup);
    final signal = signals[HrisWorkspaceId.peopleOps];

    expect(signal, isNotNull);
    expect(signal!.severity, DashboardRiskSeverity.critical);
    expect(signal.shouldHighlight, isTrue);
    expect(signal.compactLabel, 'Critical 8');
    expect(signal.detailLabel, 'Critical - 8 risks');
  });
}
