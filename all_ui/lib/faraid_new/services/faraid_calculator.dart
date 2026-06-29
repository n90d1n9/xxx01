// calculators/base_calculator.dart
import '../models/faraid_model.dart';

abstract class FaraidCalculator {
  FaraidResult calculate(InheritanceCase inheritanceCase);

  void assignShare({
    required Map<String, double> shares,
    required Map<String, String> reasons,
    required Heir heir,
    required double share,
    required String reason,
  }) {
    shares[heir.id] = share;
    reasons[heir.id] = reason;
  }

  void assignEqualShares({
    required Map<String, double> shares,
    required Map<String, String> reasons,
    required List<Heir> heirs,
    required double totalShare,
    required String reasonTemplate,
  }) {
    if (heirs.isEmpty) return;

    final sharePerHeir = totalShare / heirs.length;
    for (final heir in heirs) {
      final reason =
          reasonTemplate.replaceAll('{share}', _formatShare(sharePerHeir));
      assignShare(
        shares: shares,
        reasons: reasons,
        heir: heir,
        share: sharePerHeir,
        reason: reason,
      );
    }
  }

  String _formatShare(double share) {
    if (share == 0.5) return '1/2';
    if (share == 0.25) return '1/4';
    if (share == 0.125) return '1/8';
    if (share == 1.0 / 6.0) return '1/6';
    if (share == 1.0 / 3.0) return '1/3';
    if (share == 2.0 / 3.0) return '2/3';
    return share.toStringAsFixed(3);
  }
}
