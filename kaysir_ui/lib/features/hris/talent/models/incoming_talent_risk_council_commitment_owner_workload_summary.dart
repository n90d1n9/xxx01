import 'incoming_talent_risk_council_commitment_owner_workload_item.dart';

class IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary {
  final int ownerCount;
  final int criticalOwnerCount;
  final int stretchedOwnerCount;
  final int balancedOwnerCount;
  final int clearOwnerCount;
  final int totalActionCount;
  final int openActionCount;
  final int blockedActionCount;
  final int overdueActionCount;
  final int attentionOwnerCount;
  final String nextAction;

  const IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary({
    required this.ownerCount,
    required this.criticalOwnerCount,
    required this.stretchedOwnerCount,
    required this.balancedOwnerCount,
    required this.clearOwnerCount,
    required this.totalActionCount,
    required this.openActionCount,
    required this.blockedActionCount,
    required this.overdueActionCount,
    required this.attentionOwnerCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary.fromItems(
    List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem> items,
  ) {
    final criticalOwnerCount = _countByLoad(
      items,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.critical,
    );
    final stretchedOwnerCount = _countByLoad(
      items,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched,
    );
    final balancedOwnerCount = _countByLoad(
      items,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced,
    );
    final clearOwnerCount = _countByLoad(
      items,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.clear,
    );
    final totalActionCount = items.fold<int>(0, (sum, item) {
      return sum + item.totalCount;
    });
    final openActionCount = items.fold<int>(0, (sum, item) {
      return sum + item.openCount;
    });
    final blockedActionCount = items.fold<int>(0, (sum, item) {
      return sum + item.blockedCount;
    });
    final overdueActionCount = items.fold<int>(0, (sum, item) {
      return sum + item.overdueCount;
    });
    final attentionOwnerCount =
        items.where((item) => item.needsAttention).length;

    return IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary(
      ownerCount: items.length,
      criticalOwnerCount: criticalOwnerCount,
      stretchedOwnerCount: stretchedOwnerCount,
      balancedOwnerCount: balancedOwnerCount,
      clearOwnerCount: clearOwnerCount,
      totalActionCount: totalActionCount,
      openActionCount: openActionCount,
      blockedActionCount: blockedActionCount,
      overdueActionCount: overdueActionCount,
      attentionOwnerCount: attentionOwnerCount,
      nextAction: _nextAction(
        ownerCount: items.length,
        criticalOwnerCount: criticalOwnerCount,
        stretchedOwnerCount: stretchedOwnerCount,
        openActionCount: openActionCount,
      ),
    );
  }
}

int _countByLoad(
  List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem> items,
  IncomingTalentRiskCouncilCommitmentOwnerLoad load,
) {
  return items.where((item) => item.load == load).length;
}

String _nextAction({
  required int ownerCount,
  required int criticalOwnerCount,
  required int stretchedOwnerCount,
  required int openActionCount,
}) {
  if (ownerCount == 0) {
    return 'Create council commitment actions before reviewing owner workload.';
  }
  if (criticalOwnerCount > 0) {
    return 'Rebalance $criticalOwnerCount critical owner ${_plural(criticalOwnerCount, 'workload')}.';
  }
  if (stretchedOwnerCount > 0) {
    return 'Support $stretchedOwnerCount stretched owner ${_plural(stretchedOwnerCount, 'workload')}.';
  }
  if (openActionCount > 0) {
    return 'Track $openActionCount open owner-owned commitment ${_plural(openActionCount, 'action')}.';
  }
  return 'Council commitment owner workloads are clear.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
