import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_intervention_models.dart';
import '../models/candidate_development_models.dart';
import '../states/candidate_development_check_in_provider.dart';
import '../states/candidate_development_intervention_provider.dart';
import '../states/candidate_development_provider.dart';
import 'candidate_development_intervention_form.dart';
import 'candidate_development_intervention_summary_tile.dart';
import 'candidate_development_intervention_tile.dart';

class CandidateDevelopmentInterventionPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateDevelopmentInterventionPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.packets,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectives = _visibleObjectives(
      ref.watch(candidateDevelopmentObjectivesProvider),
    );
    final checkIns = _visibleCheckIns(
      ref.watch(candidateDevelopmentCheckInsProvider),
      objectives,
    );
    final interventions = _visibleInterventions(
      ref.watch(candidateDevelopmentInterventionsProvider),
      checkIns,
    );
    final summary = CandidateDevelopmentInterventionSummary.fromInterventions(
      interventions: interventions,
      asOfDate: asOfDate,
    );

    return HrisSectionPanel(
      icon: Icons.handyman_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateDevelopmentInterventionSummaryTile(summary: summary),
        CandidateDevelopmentInterventionForm(checkIns: checkIns),
        if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('Submit a development check-in before interventions.'),
          )
        else if (interventions.isEmpty)
          const HrisListSurface(
            child: Text('No development interventions submitted yet.'),
          )
        else
          for (final intervention in interventions)
            CandidateDevelopmentInterventionTile(
              intervention: intervention,
              asOfDate: asOfDate,
              onStart: () => _startIntervention(context, ref, intervention),
              onResolve: () => _resolveIntervention(context, ref, intervention),
            ),
      ],
    );
  }

  List<CandidateDevelopmentObjective> _visibleObjectives(
    List<CandidateDevelopmentObjective> objectives,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return objectives
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  List<CandidateDevelopmentCheckIn> _visibleCheckIns(
    List<CandidateDevelopmentCheckIn> checkIns,
    List<CandidateDevelopmentObjective> objectives,
  ) {
    final objectiveIds = objectives.map((item) => item.id).toSet();
    return checkIns
        .where((item) => objectiveIds.contains(item.objectiveId))
        .toList();
  }

  List<CandidateDevelopmentIntervention> _visibleInterventions(
    List<CandidateDevelopmentIntervention> interventions,
    List<CandidateDevelopmentCheckIn> checkIns,
  ) {
    final checkInIds = checkIns.map((item) => item.id).toSet();
    return interventions
        .where((item) => checkInIds.contains(item.checkInId))
        .toList();
  }

  void _startIntervention(
    BuildContext context,
    WidgetRef ref,
    CandidateDevelopmentIntervention intervention,
  ) {
    ref
        .read(candidateDevelopmentInterventionsProvider.notifier)
        .start(intervention.id);
    _showMessage(context, '${intervention.type.label} started');
  }

  void _resolveIntervention(
    BuildContext context,
    WidgetRef ref,
    CandidateDevelopmentIntervention intervention,
  ) {
    ref
        .read(candidateDevelopmentInterventionsProvider.notifier)
        .resolve(intervention.id);
    _showMessage(context, '${intervention.type.label} resolved');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
