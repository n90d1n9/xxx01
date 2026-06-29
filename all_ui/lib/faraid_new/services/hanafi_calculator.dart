// calculators/sunni_hanafi_calculator.dart
import '../models/family_member.dart';
import '../models/faraid_model.dart';
import 'faraid_calculator.dart';

class SunniHanafiCalculator extends FaraidCalculator {
  @override
  FaraidResult calculate(InheritanceCase inheritanceCase) {
    final shares = <String, double>{};
    final reasons = <String, String>{};
    final steps = <String>[];

    steps.add('Starting ${inheritanceCase.method.name} calculation');

    // Phase 1: Calculate fixed shares (spouses and parents)
    _calculateSpouseShares(inheritanceCase, shares, reasons, steps);
    _calculateParentShares(inheritanceCase, shares, reasons, steps);

    // Phase 2: Calculate remaining share
    final remainingShare = 1.0 - _sumShares(shares);
    steps.add(
        'Remaining share after fixed shares: ${_formatShare(remainingShare)}');

    // Phase 3: Distribute to children or siblings
    if (inheritanceCase.hasChildren) {
      _calculateChildrenShares(
          inheritanceCase, shares, reasons, remainingShare, steps);
    } else if (inheritanceCase.hasSiblings) {
      _calculateSiblingShares(
          inheritanceCase, shares, reasons, remainingShare, steps);
    } else if (inheritanceCase.fathers.isNotEmpty) {
      _assignToFatherAsResiduary(
          inheritanceCase, shares, reasons, remainingShare, steps);
    }

    // Phase 4: Handle any remaining share
    final finalRemaining = 1.0 - _sumShares(shares);
    if (finalRemaining > 0.001) {
      steps.add(
          'Applying Radd (proportional increase) for remaining: ${_formatShare(finalRemaining)}');
      _applyRadd(shares, finalRemaining);
    }

    steps
        .add('Calculation completed. Total distributed: ${_sumShares(shares)}');

    return FaraidResult(
      shares: shares,
      reasons: reasons,
      remainingShare: finalRemaining,
      calculationSteps: steps,
    );
  }

  void _calculateSpouseShares(
    InheritanceCase inheritanceCase,
    Map<String, double> shares,
    Map<String, String> reasons,
    List<String> steps,
  ) {
    for (final spouse in inheritanceCase.spouses) {
      double share;
      String reason;

      if (inheritanceCase.hasChildren) {
        share = inheritanceCase.deceasedGender == Gender.male ? 0.125 : 0.25;
        reason = inheritanceCase.deceasedGender == Gender.male
            ? 'Istri mendapatkan 1/8 (12.5%) karena almarhum memiliki anak (Quran 4:12)'
            : 'Suami mendapatkan 1/4 (25%) karena almarhumah memiliki anak (Quran 4:12)';
      } else {
        share = inheritanceCase.deceasedGender == Gender.male ? 0.25 : 0.5;
        reason = inheritanceCase.deceasedGender == Gender.male
            ? 'Istri mendapatkan 1/4 (25%) karena almarhum tidak memiliki anak (Quran 4:12)'
            : 'Suami mendapatkan 1/2 (50%) karena almarhumah tidak memiliki anak (Quran 4:12)';
      }

      assignShare(
        shares: shares,
        reasons: reasons,
        heir: spouse,
        share: share,
        reason: reason,
      );

      steps.add('Assigned ${_formatShare(share)} to ${spouse.relation}');
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

  void _calculateParentShares(
    InheritanceCase inheritanceCase,
    Map<String, double> shares,
    Map<String, String> reasons,
    List<String> steps,
  ) {
    final mother = inheritanceCase.mothers.firstOrNull;
    final father = inheritanceCase.fathers.firstOrNull;

    // Mother's share
    if (mother != null) {
      double motherShare;
      String motherReason;

      if (inheritanceCase.hasChildren || inheritanceCase.hasSiblings) {
        motherShare = 1.0 / 6.0;
        motherReason =
            'Ibu mendapatkan 1/6 (16.67%) karena adanya anak atau saudara (Quran 4:11)';
      } else {
        motherShare = 1.0 / 3.0;
        motherReason =
            'Ibu mendapatkan 1/3 (33.33%) karena tidak ada anak atau saudara (Quran 4:11)';
      }

      assignShare(
        shares: shares,
        reasons: reasons,
        heir: mother,
        share: motherShare,
        reason: motherReason,
      );
      steps.add('Assigned ${_formatShare(motherShare)} to mother');
    }

    // Father's share as fixed portion (when there are children)
    if (father != null && inheritanceCase.hasChildren) {
      final fatherShare = 1.0 / 6.0;
      assignShare(
        shares: shares,
        reasons: reasons,
        heir: father,
        share: fatherShare,
        reason:
            'Ayah mendapatkan 1/6 (16.67%) sebagai bagian tetap karena adanya anak (Quran 4:11)',
      );
      steps.add(
          'Assigned ${_formatShare(fatherShare)} to father as fixed share');
    }
  }

  void _calculateChildrenShares(
    InheritanceCase inheritanceCase,
    Map<String, double> shares,
    Map<String, String> reasons,
    double remainingShare,
    List<String> steps,
  ) {
    final sons = inheritanceCase.sons;
    final daughters = inheritanceCase.daughters;

    if (sons.isEmpty && daughters.isNotEmpty) {
      // Only daughters - they get fixed shares + residuary
      if (daughters.length == 1) {
        assignEqualShares(
          shares: shares,
          reasons: reasons,
          heirs: daughters,
          totalShare: 0.5,
          reasonTemplate:
              'Anak perempuan tunggal mendapatkan 1/2 sebagai bagian tetap',
        );
        steps.add('Assigned 1/2 to single daughter');
      } else {
        assignEqualShares(
          shares: shares,
          reasons: reasons,
          heirs: daughters,
          totalShare: 2.0 / 3.0,
          reasonTemplate:
              'Anak perempuan kolektif mendapatkan 2/3 sebagai bagian tetap',
        );
        steps.add('Assigned 2/3 to multiple daughters');
      }

      // Distribute remaining to daughters as residuary
      final currentRemaining = remainingShare - _sumShares(shares);
      if (currentRemaining > 0) {
        assignEqualShares(
          shares: shares,
          reasons: reasons,
          heirs: daughters,
          totalShare: currentRemaining,
          reasonTemplate: 'Anak perempuan mendapatkan {share} sebagai \'asabah',
        );
        steps.add(
            'Distributed remaining ${_formatShare(currentRemaining)} to daughters as residuary');
      }
    } else if (sons.isNotEmpty) {
      // Sons exist - 2:1 ratio with daughters
      final totalUnits = (sons.length * 2) + daughters.length;
      final unitValue = remainingShare / totalUnits;

      for (final son in sons) {
        assignShare(
          shares: shares,
          reasons: reasons,
          heir: son,
          share: unitValue * 2,
          reason:
              'Anak laki-laki mendapatkan 2 bagian (rasio 2:1) sebagai \'asabah',
        );
      }

      for (final daughter in daughters) {
        assignShare(
          shares: shares,
          reasons: reasons,
          heir: daughter,
          share: unitValue,
          reason:
              'Anak perempuan mendapatkan 1 bagian (rasio 2:1) sebagai \'asabah',
        );
      }

      steps.add(
          'Distributed ${_formatShare(remainingShare)} to children with 2:1 ratio (sons:daughters)');
    }
  }

  void _calculateSiblingShares(
    InheritanceCase inheritanceCase,
    Map<String, double> shares,
    Map<String, String> reasons,
    double remainingShare,
    List<String> steps,
  ) {
    final brothers = inheritanceCase.brothers;
    final sisters = inheritanceCase.sisters;

    if (brothers.isNotEmpty || sisters.isNotEmpty) {
      final totalUnits = (brothers.length * 2) + sisters.length;
      final unitValue = remainingShare / totalUnits;

      for (final brother in brothers) {
        assignShare(
          shares: shares,
          reasons: reasons,
          heir: brother,
          share: unitValue * 2,
          reason:
              'Saudara laki-laki mendapatkan 2 bagian (rasio 2:1) sebagai \'asabah (Quran 4:176)',
        );
      }

      for (final sister in sisters) {
        assignShare(
          shares: shares,
          reasons: reasons,
          heir: sister,
          share: unitValue,
          reason:
              'Saudara perempuan mendapatkan 1 bagian (rasio 2:1) sebagai \'asabah (Quran 4:176)',
        );
      }

      steps.add(
          'Distributed ${_formatShare(remainingShare)} to siblings with 2:1 ratio');
    }
  }

  void _assignToFatherAsResiduary(
    InheritanceCase inheritanceCase,
    Map<String, double> shares,
    Map<String, String> reasons,
    double remainingShare,
    List<String> steps,
  ) {
    final father = inheritanceCase.fathers.firstOrNull;
    if (father != null && remainingShare > 0) {
      final currentFatherShare = shares[father.id] ?? 0.0;
      assignShare(
        shares: shares,
        reasons: reasons,
        heir: father,
        share: currentFatherShare + remainingShare,
        reason:
            'Ayah mendapatkan ${_formatShare(remainingShare)} sebagai \'asabah karena tidak ada anak',
      );
      steps.add(
          'Assigned remaining ${_formatShare(remainingShare)} to father as residuary');
    }
  }

  void _applyRadd(Map<String, double> shares, double remainingShare) {
    final totalAssigned = _sumShares(shares);
    if (totalAssigned > 0) {
      final multiplier = (totalAssigned + remainingShare) / totalAssigned;
      shares.updateAll((id, share) => share * multiplier);
    }
  }

  double _sumShares(Map<String, double> shares) {
    return shares.values.fold(0.0, (sum, share) => sum + share);
  }
}
