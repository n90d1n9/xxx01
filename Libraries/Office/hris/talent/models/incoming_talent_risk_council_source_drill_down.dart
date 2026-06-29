import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';
import 'incoming_talent_risk_council_queue_item.dart';
import 'incoming_talent_risk_council_sla_item.dart';
import 'incoming_talent_risk_council_source_pressure.dart';

/// Operational drill-down for the currently focused risk council source.
class IncomingTalentRiskCouncilSourceDrillDown {
  final IncomingTalentRiskCouncilQueueSource? source;
  final bool isAutoFocused;
  final IncomingTalentRiskCouncilSourcePressure? pressure;
  final List<IncomingTalentRiskCouncilQueueItem> queueItems;
  final List<IncomingTalentRiskCouncilDecision> decisions;
  final List<IncomingTalentRiskCouncilFollowUp> followUps;
  final List<IncomingTalentRiskCouncilSlaItem> slaItems;

  const IncomingTalentRiskCouncilSourceDrillDown({
    required this.source,
    required this.isAutoFocused,
    required this.pressure,
    required this.queueItems,
    required this.decisions,
    required this.followUps,
    required this.slaItems,
  });

  int get totalWorkCount {
    return queueItems.length + decisions.length + followUps.length;
  }

  int get activeSlaCount => slaItems.length;

  int get urgentSlaCount {
    return slaItems
        .where(
          (item) =>
              item.status == IncomingTalentRiskCouncilSlaStatus.blocked ||
              item.status == IncomingTalentRiskCouncilSlaStatus.escalated ||
              item.status == IncomingTalentRiskCouncilSlaStatus.overdue,
        )
        .length;
  }

  bool get hasWork =>
      source != null && (totalWorkCount > 0 || slaItems.isNotEmpty);

  String get sourceLabel => source?.label ?? 'No active source';

  String get focusLabel {
    if (source == null) return 'No source focus';
    return isAutoFocused ? 'Auto-focused source' : 'Selected source';
  }

  String get nextAction {
    if (source == null) return 'No active council source needs drill-down.';
    if (pressure != null) return pressure!.nextAction;
    return 'No ${sourceLabel.toLowerCase()} council work needs action.';
  }

  String get evidenceSummary {
    if (source == null) {
      return 'Council source drill-down will appear when SLA work is active.';
    }

    return '${queueItems.length} queue, ${decisions.length} decisions, '
        '${followUps.length} follow-ups, $activeSlaCount SLA items';
  }
}
