import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_provider.dart';
import 'incoming_talent_succession_bench_action_provider.dart';
import 'incoming_talent_succession_bench_check_in_provider.dart';
import 'incoming_talent_succession_bench_replenishment_provider.dart';
import 'incoming_talent_succession_provider.dart';
import 'incoming_talent_succession_transition_intervention_provider.dart';
import 'incoming_talent_succession_transition_outcome_review_provider.dart';
import 'incoming_talent_succession_transition_pulse_provider.dart';

final incomingTalentSuccessionCoverageDashboardProvider =
    Provider<IncomingTalentSuccessionCoverageDashboard>((ref) {
      return IncomingTalentSuccessionCoverageDashboard.fromSignals(
        candidates: ref.watch(
          filteredIncomingTalentSuccessionCandidatesProvider,
        ),
        activationPlans: ref.watch(
          filteredIncomingTalentSuccessionActivationPlansProvider,
        ),
        transitionPulses: ref.watch(
          filteredIncomingTalentSuccessionTransitionPulsesProvider,
        ),
        transitionInterventions: ref.watch(
          filteredIncomingTalentSuccessionTransitionInterventionsProvider,
        ),
        transitionOutcomeReviews: ref.watch(
          filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
        ),
        benchPlans: ref.watch(
          filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
        ),
        benchCheckIns: ref.watch(
          filteredIncomingTalentSuccessionBenchCheckInsProvider,
        ),
        benchActions: ref.watch(
          filteredIncomingTalentSuccessionBenchActionsProvider,
        ),
      );
    });
