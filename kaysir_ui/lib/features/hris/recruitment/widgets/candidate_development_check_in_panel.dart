import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_models.dart';
import '../states/candidate_development_check_in_provider.dart';
import '../states/candidate_development_provider.dart';
import 'candidate_development_check_in_form.dart';
import 'candidate_development_check_in_summary_tile.dart';
import 'candidate_development_check_in_tile.dart';

class CandidateDevelopmentCheckInPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateDevelopmentCheckInPanel({
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
    final summary = CandidateDevelopmentCheckInSummary.fromCheckIns(
      checkIns: checkIns,
      asOfDate: asOfDate,
    );

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateDevelopmentCheckInSummaryTile(summary: summary),
        CandidateDevelopmentCheckInForm(objectives: objectives),
        if (objectives.isEmpty)
          const HrisListSurface(
            child: Text('Submit a development objective before check-ins.'),
          )
        else if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('No development check-ins submitted yet.'),
          )
        else
          for (final checkIn in checkIns)
            CandidateDevelopmentCheckInTile(
              checkIn: checkIn,
              asOfDate: asOfDate,
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
}
