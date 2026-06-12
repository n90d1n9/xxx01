import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_command_center_models.dart';
import 'incoming_talent_career_path_provider.dart';
import 'incoming_talent_health_dashboard_provider.dart';
import 'incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_succession_coverage_dashboard_provider.dart';
import 'incoming_talent_training_session_provider.dart';

/// Executive command center for cross-HRIS talent governance.
final incomingTalentGovernanceCommandCenterProvider =
    Provider<IncomingTalentGovernanceCommandCenter>((ref) {
      return buildIncomingTalentGovernanceCommandCenter(
        healthDashboard: ref.watch(incomingTalentHealthDashboardProvider),
        slaSummary: ref.watch(incomingTalentOperatingSlaSummaryProvider),
        escalationSummary: ref.watch(
          incomingTalentOperatingEscalationSummaryProvider,
        ),
        assuranceSummary: ref.watch(
          incomingTalentOperatingAssuranceSummaryProvider,
        ),
        remediationSummary: ref.watch(
          incomingTalentOperatingAssuranceRemediationSummaryProvider,
        ),
        executionSummary: ref.watch(
          incomingTalentOperatingAssuranceExecutionSummaryProvider,
        ),
        successionDashboard: ref.watch(
          incomingTalentSuccessionCoverageDashboardProvider,
        ),
        trainingSummary: ref.watch(
          incomingTalentTrainingSessionSummaryProvider,
        ),
        careerPathSummary: ref.watch(incomingTalentCareerPathSummaryProvider),
      );
    });
