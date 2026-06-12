import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_models.dart';
import '../states/candidate_development_provider.dart';
import 'candidate_development_form.dart';
import 'candidate_development_summary_tile.dart';
import 'candidate_development_tile.dart';

class CandidateDevelopmentPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateDevelopmentPanel({
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
    final summary = CandidateDevelopmentObjectiveSummary.fromObjectives(
      objectives: objectives,
      asOfDate: asOfDate,
    );

    return HrisSectionPanel(
      icon: Icons.track_changes_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateDevelopmentSummaryTile(summary: summary),
        CandidateDevelopmentForm(packets: packets),
        if (objectives.isEmpty)
          const HrisListSurface(
            child: Text('No submitted development objectives yet.'),
          )
        else
          for (final objective in objectives)
            CandidateDevelopmentObjectiveTile(
              objective: objective,
              asOfDate: asOfDate,
              onActivate: () => _activateObjective(context, ref, objective),
              onComplete: () => _completeObjective(context, ref, objective),
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

  void _activateObjective(
    BuildContext context,
    WidgetRef ref,
    CandidateDevelopmentObjective objective,
  ) {
    ref
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .activate(objective.id);
    _showMessage(context, '${objective.objectiveTitle} activated');
  }

  void _completeObjective(
    BuildContext context,
    WidgetRef ref,
    CandidateDevelopmentObjective objective,
  ) {
    ref
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .complete(objective.id);
    _showMessage(context, '${objective.objectiveTitle} completed');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
