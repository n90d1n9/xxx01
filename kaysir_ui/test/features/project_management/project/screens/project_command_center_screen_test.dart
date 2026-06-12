import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_delivery_command_view_repository.dart';
import 'package:kaysir/features/project_management/project/screens/project_command_center_screen.dart';
import 'package:kaysir/features/project_management/project/states/project_delivery_command_provider.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_pulse_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_command_components.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_command_lens_bar.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_saved_lens_profile_bar.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_saved_lens_strip.dart';
import 'package:kaysir/features/project_management/project/widgets/project_milestone_forecast_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_resource_capacity_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_exposure_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project command center renders delivery queue', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectDeliveryCommandViewRepositoryProvider.overrideWithValue(
            ProjectDeliveryCommandViewRepository(
              store: MemoryProjectDeliveryCommandViewSnapshotStore(),
            ),
          ),
        ],
        child: const MaterialApp(home: ProjectCommandCenterScreen()),
      ),
    );

    expect(find.text('Delivery Command Center'), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsNWidgets(5));
    expect(find.byType(ProjectResourceCapacityPanel), findsOneWidget);
    expect(find.byType(ProjectRiskExposurePanel), findsOneWidget);
    expect(find.byType(ProjectBudgetPulsePanel), findsOneWidget);
    expect(find.byType(ProjectMilestoneForecastPanel), findsOneWidget);
    expect(find.byType(ProjectDeliverySavedLensProfileBar), findsOneWidget);
    expect(find.byType(ProjectDeliverySavedLensStrip), findsOneWidget);
    expect(find.byType(ProjectDeliveryCommandLensBar), findsOneWidget);
    expect(find.byType(ProjectDeliveryCommandFilteredQueue), findsOneWidget);
    expect(find.byType(ProjectDeliveryCommandQueue), findsOneWidget);
    expect(find.text('Resource Capacity'), findsOneWidget);
    expect(find.text('Risk Exposure'), findsOneWidget);
    expect(find.text('Budget Pulse'), findsOneWidget);
    expect(find.text('Milestone Forecast'), findsOneWidget);
    expect(find.text('Priority Queue'), findsOneWidget);
    expect(find.text('Delivery Lead'), findsOneWidget);
    expect(find.text('Finance Partner'), findsOneWidget);
    expect(find.text('Release Desk'), findsOneWidget);
    expect(find.text('Saved Lenses'), findsOneWidget);
    expect(find.text('Firefight'), findsOneWidget);
    expect(find.text('Budget Control'), findsOneWidget);
    expect(find.text('Critical Now'), findsOneWidget);
    expect(find.text('All Priorities'), findsOneWidget);
    expect(find.text('All Signals'), findsOneWidget);
    expect(find.text('API contract drift'), findsWidgets);
    expect(find.text('API Ready'), findsWidgets);
    expect(find.text('Budget pressure'), findsWidgets);
    expect(find.text('Project is blocked'), findsOneWidget);
  });
}
