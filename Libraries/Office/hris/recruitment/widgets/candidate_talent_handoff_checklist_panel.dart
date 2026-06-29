import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_talent_handoff_checklist_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import '../states/candidate_talent_handoff_checklist_provider.dart';
import '../states/candidate_talent_handoff_provider.dart';
import 'candidate_talent_handoff_checklist_coverage_tile.dart';
import 'candidate_talent_handoff_checklist_form.dart';
import 'candidate_talent_handoff_checklist_summary_tile.dart';
import 'candidate_talent_handoff_checklist_tile.dart';

class CandidateTalentHandoffChecklistPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateTalentHandoffChecklistPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.packets,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handoffs = _visibleHandoffs(
      ref.watch(candidateTalentHandoffsProvider),
    );
    final items = _visibleItems(
      ref.watch(candidateTalentHandoffChecklistItemsProvider),
    );
    final coverages = _visibleCoverages(
      ref.watch(candidateTalentHandoffChecklistCoverageProvider),
    );
    final summary = CandidateTalentHandoffChecklistSummary.fromItems(
      items: items,
      asOfDate: asOfDate,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateTalentHandoffChecklistSummaryTile(summary: summary),
        CandidateTalentHandoffChecklistForm(handoffs: handoffs),
        for (final coverage in coverages)
          CandidateTalentHandoffChecklistCoverageTile(
            coverage: coverage,
            onGenerate: () => _generateTasks(context, ref, coverage, handoffs),
          ),
        if (handoffs.isEmpty)
          const HrisListSurface(
            child: Text('Submit a talent handoff before checklist tasks.'),
          )
        else if (items.isEmpty)
          const HrisListSurface(
            child: Text('No handoff checklist tasks submitted yet.'),
          )
        else
          for (final item in items)
            CandidateTalentHandoffChecklistTile(
              item: item,
              asOfDate: asOfDate,
              onStart: () => _startItem(context, ref, item),
              onComplete: () => _completeItem(context, ref, item),
              onBlock: () => _blockItem(context, ref, item),
            ),
      ],
    );
  }

  List<CandidateTalentHandoff> _visibleHandoffs(
    List<CandidateTalentHandoff> handoffs,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return handoffs
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  List<CandidateTalentHandoffChecklistItem> _visibleItems(
    List<CandidateTalentHandoffChecklistItem> items,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return items
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  List<CandidateTalentHandoffChecklistCoverage> _visibleCoverages(
    List<CandidateTalentHandoffChecklistCoverage> coverages,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return coverages
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  void _generateTasks(
    BuildContext context,
    WidgetRef ref,
    CandidateTalentHandoffChecklistCoverage coverage,
    List<CandidateTalentHandoff> handoffs,
  ) {
    final handoff = handoffs.firstWhere(
      (item) => item.id == coverage.handoffId,
    );
    final generated = ref
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .generateForHandoff(handoff: handoff, asOfDate: asOfDate);
    final message =
        generated.isEmpty
            ? 'Checklist tasks already generated for ${handoff.candidateName}'
            : '${generated.length} checklist tasks generated for ${handoff.candidateName}';
    _showMessage(context, message);
  }

  void _startItem(
    BuildContext context,
    WidgetRef ref,
    CandidateTalentHandoffChecklistItem item,
  ) {
    ref
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .start(item.id);
    _showMessage(context, '${item.title} started');
  }

  void _completeItem(
    BuildContext context,
    WidgetRef ref,
    CandidateTalentHandoffChecklistItem item,
  ) {
    ref
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .complete(item.id);
    _showMessage(context, '${item.title} completed');
  }

  void _blockItem(
    BuildContext context,
    WidgetRef ref,
    CandidateTalentHandoffChecklistItem item,
  ) {
    ref
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .block(item.id);
    _showMessage(context, '${item.title} blocked');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
