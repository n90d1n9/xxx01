import 'incoming_talent_operating_inbox_owner_digest.dart';

/// Summary of owner concentration across the talent operating inbox.
class IncomingTalentOperatingInboxOwnerDigestSummary {
  final int ownerCount;
  final int criticalOwnerCount;
  final int stretchedOwnerCount;
  final int balancedOwnerCount;
  final int clearOwnerCount;
  final int totalItemCount;
  final int criticalItemCount;
  final int overdueItemCount;
  final int dueSoonItemCount;
  final int attentionOwnerCount;
  final String nextAction;

  const IncomingTalentOperatingInboxOwnerDigestSummary({
    required this.ownerCount,
    required this.criticalOwnerCount,
    required this.stretchedOwnerCount,
    required this.balancedOwnerCount,
    required this.clearOwnerCount,
    required this.totalItemCount,
    required this.criticalItemCount,
    required this.overdueItemCount,
    required this.dueSoonItemCount,
    required this.attentionOwnerCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingInboxOwnerDigestSummary.fromDigests(
    List<IncomingTalentOperatingInboxOwnerDigest> digests,
  ) {
    final criticalOwnerCount = _countByLoad(
      digests,
      IncomingTalentOperatingInboxOwnerLoad.critical,
    );
    final stretchedOwnerCount = _countByLoad(
      digests,
      IncomingTalentOperatingInboxOwnerLoad.stretched,
    );
    final balancedOwnerCount = _countByLoad(
      digests,
      IncomingTalentOperatingInboxOwnerLoad.balanced,
    );
    final clearOwnerCount = _countByLoad(
      digests,
      IncomingTalentOperatingInboxOwnerLoad.clear,
    );
    final totalItemCount = digests.fold<int>(
      0,
      (sum, digest) => sum + digest.totalCount,
    );
    final criticalItemCount = digests.fold<int>(
      0,
      (sum, digest) => sum + digest.criticalCount,
    );
    final overdueItemCount = digests.fold<int>(
      0,
      (sum, digest) => sum + digest.overdueCount,
    );
    final dueSoonItemCount = digests.fold<int>(
      0,
      (sum, digest) => sum + digest.dueSoonCount,
    );
    final attentionOwnerCount =
        digests.where((digest) => digest.needsAttention).length;

    return IncomingTalentOperatingInboxOwnerDigestSummary(
      ownerCount: digests.length,
      criticalOwnerCount: criticalOwnerCount,
      stretchedOwnerCount: stretchedOwnerCount,
      balancedOwnerCount: balancedOwnerCount,
      clearOwnerCount: clearOwnerCount,
      totalItemCount: totalItemCount,
      criticalItemCount: criticalItemCount,
      overdueItemCount: overdueItemCount,
      dueSoonItemCount: dueSoonItemCount,
      attentionOwnerCount: attentionOwnerCount,
      nextAction: _nextAction(
        ownerCount: digests.length,
        criticalOwnerCount: criticalOwnerCount,
        stretchedOwnerCount: stretchedOwnerCount,
        overdueItemCount: overdueItemCount,
        dueSoonItemCount: dueSoonItemCount,
        totalItemCount: totalItemCount,
      ),
    );
  }
}

int _countByLoad(
  List<IncomingTalentOperatingInboxOwnerDigest> digests,
  IncomingTalentOperatingInboxOwnerLoad load,
) {
  return digests.where((digest) => digest.load == load).length;
}

String _nextAction({
  required int ownerCount,
  required int criticalOwnerCount,
  required int stretchedOwnerCount,
  required int overdueItemCount,
  required int dueSoonItemCount,
  required int totalItemCount,
}) {
  if (ownerCount == 0) {
    return 'Talent owner workload digest is clear.';
  }
  if (criticalOwnerCount > 0) {
    return 'Support $criticalOwnerCount critical talent owner ${_plural(criticalOwnerCount, 'workload')}.';
  }
  if (stretchedOwnerCount > 0) {
    return 'Support $stretchedOwnerCount stretched talent owner ${_plural(stretchedOwnerCount, 'workload')}.';
  }
  if (overdueItemCount > 0) {
    return 'Recover $overdueItemCount overdue owner-owned talent inbox ${_plural(overdueItemCount, 'item')}.';
  }
  if (dueSoonItemCount > 0) {
    return 'Close $dueSoonItemCount owner-owned talent inbox ${_plural(dueSoonItemCount, 'item')} due soon.';
  }
  return 'Track $totalItemCount owner-owned talent inbox ${_plural(totalItemCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
