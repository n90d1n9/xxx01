import '../models/family.dart';
import '../models/gender.dart';
import '../models/mahram_status.dart';

class IslamicInheritanceCalculator {
  final Map<String, FamilyMember> members;
  final List<FamilyRelation> relations;
  final String deceasedId;
  final double estateValue;

  IslamicInheritanceCalculator({
    required this.members,
    required this.relations,
    required this.deceasedId,
    required this.estateValue,
  });

  Map<String, InheritanceInfo> calculate() {
    final deceased = members[deceasedId];
    if (deceased == null) return {};

    final result = <String, InheritanceInfo>{};
    final shares = <String, double>{};
    final explanations = <String, String>{};
    final categories = <String, String>{};
    final calculations = <String, String>{};

    // Get living relatives
    final spouses =
        _getPasangans(deceasedId).where((id) => !_isDeceased(id)).toList();
    final sons = _getAnak Laki-lakis(deceasedId).where((id) => !_isDeceased(id)).toList();
    final daughters =
        _getAnak Perempuans(deceasedId).where((id) => !_isDeceased(id)).toList();
    final father = _getAyah(deceasedId);
    final mother = _getIbu(deceasedId);
    final brothers =
        _getBrothers(deceasedId).where((id) => !_isDeceased(id)).toList();
    final sisters =
        _getSisters(deceasedId).where((id) => !_isDeceased(id)).toList();
    final paternalGrandfather = _getPaternGrandfather(deceasedId);
    final maternalGrandmother = _getMaternalGrandmother(deceasedId);
    final paternalGrandmother = _getPaternalGrandmother(deceasedId);

    final hasAnak Laki-lakis = sons.isNotEmpty;
    final hasAnak Perempuans = daughters.isNotEmpty;
    final hasChildren = hasAnak Laki-lakis || hasAnak Perempuans;
    final hasAyah = father != null && !_isDeceased(father);
    final hasIbu = mother != null && !_isDeceased(mother);
    final hasBrothers = brothers.isNotEmpty;

    // 1. SPOUSE SHARES (Ashab al-Furud)
    for (final spouseId in spouses) {
      final spouse = members[spouseId]!;
      double share;
      String explanation;

      if (deceased.gender == Gender.male) {
        // Wife's share
        if (hasChildren) {
          share = 1.0 / 8.0; // 1/8
          explanation =
              'Wife receives 1/8 (12.5%) because deceased has children';
          calculations[spouseId] = '1/8 = 0.125';
        } else {
          share = 1.0 / 4.0; // 1/4
          explanation =
              'Wife receives 1/4 (25%) because deceased has no children';
          calculations[spouseId] = '1/4 = 0.25';
        }
      } else {
        // Husband's share
        if (hasChildren) {
          share = 1.0 / 4.0; // 1/4
          explanation =
              'Husband receives 1/4 (25%) because deceased has children';
          calculations[spouseId] = '1/4 = 0.25';
        } else {
          share = 1.0 / 2.0; // 1/2
          explanation =
              'Husband receives 1/2 (50%) because deceased has no children';
          calculations[spouseId] = '1/2 = 0.5';
        }
      }

      shares[spouseId] = share;
      explanations[spouseId] = explanation;
      categories[spouseId] = 'Ashab al-Furud (Fixed Heirs)';
    }

    // 2. FATHER'S SHARE
    if (hasAyah) {
      double share;
      String explanation;

      if (hasChildren) {
        share = 1.0 / 6.0; // 1/6
        explanation =
            'Ayah receives 1/6 (16.67%) because deceased has children';
        categories[father] = 'Ashab al-Furud (Fixed Heirs)';
        calculations[father] = '1/6 ≈ 0.1667';
      } else {
        // Ayah gets remainder as Asabah
        share = 0; // Will be calculated later
        explanation = 'Ayah receives remainder as Asabah (no children)';
        categories[father] = 'Asabah (Residuary)';
        calculations[father] = 'Remainder after fixed shares';
      }

      shares[father] = share;
      explanations[father] = explanation;
    }

    // 3. MOTHER'S SHARE
    if (hasIbu) {
      double share;
      String explanation;

      if (hasChildren || (brothers.length + sisters.length >= 2)) {
        share = 1.0 / 6.0; // 1/6
        explanation =
            'Ibu receives 1/6 (16.67%) because deceased has children or 2+ siblings';
        calculations[mother] = '1/6 ≈ 0.1667';
      } else if (!hasAyah) {
        share = 1.0 / 3.0; // 1/3
        explanation =
            'Ibu receives 1/3 (33.33%) - no children, no father, fewer than 2 siblings';
        calculations[mother] = '1/3 ≈ 0.3333';
      } else {
        share = 1.0 / 3.0; // 1/3 of remainder
        explanation = 'Ibu receives 1/3 (33.33%)';
        calculations[mother] = '1/3 ≈ 0.3333';
      }

      shares[mother] = share;
      explanations[mother] = explanation;
      categories[mother] = 'Ashab al-Furud (Fixed Heirs)';
    }

    // 4. DAUGHTERS' SHARES
    if (hasAnak Perempuans && !hasAnak Laki-lakis) {
      double totalAnak PerempuanShare;
      String baseExplanation;

      if (daughters.length == 1) {
        totalAnak PerempuanShare = 1.0 / 2.0; // 1/2
        baseExplanation = 'Single daughter receives 1/2 (50%)';
        calculations[daughters[0]] = '1/2 = 0.5';
      } else {
        totalAnak PerempuanShare = 2.0 / 3.0; // 2/3
        baseExplanation = 'Multiple daughters share 2/3 (66.67%)';
      }

      final perAnak Perempuan = totalAnak PerempuanShare / daughters.length;
      for (final daughterId in daughters) {
        shares[daughterId] = perAnak Perempuan;
        if (daughters.length > 1) {
          explanations[daughterId] =
              '$baseExplanation - ${(perAnak Perempuan * 100).toStringAsFixed(2)}% per daughter';
          calculations[daughterId] =
              '2/3 ÷ ${daughters.length} ≈ ${perAnak Perempuan.toStringAsFixed(4)}';
        } else {
          explanations[daughterId] = baseExplanation;
        }
        categories[daughterId] = 'Ashab al-Furud (Fixed Heirs)';
      }
    }

    // 5. CALCULATE TOTAL FIXED SHARES
    double totalFixed = shares.values.fold(0.0, (sum, share) => sum + share);

    // 6. CHILDREN AS ASABAH (if sons exist)
    if (hasAnak Laki-lakis) {
      final remainingShare = 1.0 - totalFixed;

      // Anak Laki-lakis and daughters share remainder in 2:1 ratio
      final totalUnits = (sons.length * 2) + daughters.length;
      final unitShare = remainingShare / totalUnits;

      for (final sonId in sons) {
        final sonShare = unitShare * 2;
        shares[sonId] = sonShare;
        explanations[sonId] =
            'Anak Laki-laki receives 2x share of daughter (Male:Female = 2:1 ratio)';
        categories[sonId] = 'Asabah (Residuary)';
        calculations[sonId] =
            'Remainder: ${remainingShare.toStringAsFixed(4)} × 2/$totalUnits = ${sonShare.toStringAsFixed(4)}';
      }

      for (final daughterId in daughters) {
        final daughterShare = unitShare;
        shares[daughterId] = daughterShare;
        explanations[daughterId] =
            'Anak Perempuan receives 1x share (with brothers) (Male:Female = 2:1 ratio)';
        categories[daughterId] = 'Asabah (Residuary)';
        calculations[daughterId] =
            'Remainder: ${remainingShare.toStringAsFixed(4)} × 1/$totalUnits = ${daughterShare.toStringAsFixed(4)}';
      }

      totalFixed = 1.0;
    }

    // 7. FATHER AS ASABAH (if no children and father hasn't received fixed share)
    if (!hasChildren && hasAyah && shares[father] == 0) {
      final remainingShare = 1.0 - totalFixed;
      shares[father] = remainingShare;
      explanations[father] =
          'Ayah receives remainder ${(remainingShare * 100).toStringAsFixed(2)}% as Asabah (no children)';
      calculations[father] = 'Remainder: ${remainingShare.toStringAsFixed(4)}';
      totalFixed = 1.0;
    }

    // 8. SIBLINGS AS ASABAH (if no children, no father)
    if (!hasChildren && !hasAyah && (hasBrothers || sisters.isNotEmpty)) {
      final remainingShare = 1.0 - totalFixed;

      if (remainingShare > 0) {
        final totalUnits = (brothers.length * 2) + sisters.length;
        final unitShare = remainingShare / totalUnits;

        for (final brotherId in brothers) {
          final brotherShare = unitShare * 2;
          shares[brotherId] = brotherShare;
          explanations[brotherId] =
              'Brother receives 2x share as Asabah (no children, no father)';
          categories[brotherId] = 'Asabah (Residuary)';
          calculations[brotherId] =
              'Remainder: ${remainingShare.toStringAsFixed(4)} × 2/$totalUnits = ${brotherShare.toStringAsFixed(4)}';
        }

        for (final sisterId in sisters) {
          final sisterShare = unitShare;
          shares[sisterId] = sisterShare;
          explanations[sisterId] =
              'Sister receives 1x share as Asabah (no children, no father)';
          categories[sisterId] = 'Asabah (Residuary)';
          calculations[sisterId] =
              'Remainder: ${remainingShare.toStringAsFixed(4)} × 1/$totalUnits = ${sisterShare.toStringAsFixed(4)}';
        }

        totalFixed = 1.0;
      }
    }

    // 9. AWL (Reduction) - if total shares exceed 1
    double adjustmentFactor = 1.0;
    if (totalFixed > 1.0) {
      adjustmentFactor = 1.0 / totalFixed;
      for (final heirId in shares.keys) {
        shares[heirId] = shares[heirId]! * adjustmentFactor;
        explanations[heirId] =
            '${explanations[heirId]} [Adjusted by Awl: ×${adjustmentFactor.toStringAsFixed(4)}]';
        calculations[heirId] =
            '${calculations[heirId]} × ${adjustmentFactor.toStringAsFixed(4)} (Awl adjustment)';
      }
    }

    // 10. RADD (Return) - if total shares less than 1 and no Asabah
    if (totalFixed < 1.0 && !_hasAsabah(categories)) {
      final remainder = 1.0 - totalFixed;
      final eligibleHeirs =
          shares.keys
              .where((id) => categories[id] == 'Ashab al-Furud (Fixed Heirs)')
              .toList();

      if (eligibleHeirs.isNotEmpty) {
        final totalEligibleShares = eligibleHeirs.fold(
          0.0,
          (sum, id) => sum + shares[id]!,
        );
        final distributionFactor = remainder / totalEligibleShares;

        for (final heirId in eligibleHeirs) {
          final additionalShare = shares[heirId]! * distributionFactor;
          shares[heirId] = shares[heirId]! + additionalShare;
          explanations[heirId] =
              '${explanations[heirId]} + Radd (return of remainder)';
          calculations[heirId] =
              '${calculations[heirId]} + ${additionalShare.toStringAsFixed(4)} (Radd)';
        }
      }
    }

    // Convert to InheritanceInfo
    for (final entry in shares.entries) {
      result[entry.key] = InheritanceInfo(
        heirId: entry.key,
        share: entry.value,
        explanation: explanations[entry.key] ?? '',
        category: categories[entry.key] ?? 'Other',
        actualAmount: estateValue * entry.value,
        detailedCalculation: calculations[entry.key] ?? '',
      );
    }

    return result;
  }

  bool _hasAsabah(Map<String, String> categories) {
    return categories.values.any((cat) => cat.contains('Asabah'));
  }

  bool _isDeceased(String id) => members[id]?.isDeceased ?? true;

  List<String> _getPasangans(String memberId) {
    return relations
        .where(
          (r) =>
              (r.fromId == memberId || r.toId == memberId) &&
              r.type == RelationType.spouse,
        )
        .map((r) => r.fromId == memberId ? r.toId : r.fromId)
        .toList();
  }

  List<String> _getChildren(String memberId) {
    return relations
        .where((r) => r.fromId == memberId && r.type == RelationType.child)
        .map((r) => r.toId)
        .toList();
  }

  List<String> _getAnak Laki-lakis(String memberId) {
    return _getChildren(
      memberId,
    ).where((id) => members[id]?.gender == Gender.male).toList();
  }

  List<String> _getAnak Perempuans(String memberId) {
    return _getChildren(
      memberId,
    ).where((id) => members[id]?.gender == Gender.female).toList();
  }

  String? _getAyah(String memberId) {
    final parents =
        relations
            .where((r) => r.toId == memberId && r.type == RelationType.child)
            .map((r) => r.fromId)
            .where((id) => members[id]?.gender == Gender.male)
            .toList();
    return parents.isNotEmpty ? parents.first : null;
  }

  String? _getIbu(String memberId) {
    final parents =
        relations
            .where((r) => r.toId == memberId && r.type == RelationType.child)
            .map((r) => r.fromId)
            .where((id) => members[id]?.gender == Gender.female)
            .toList();
    return parents.isNotEmpty ? parents.first : null;
  }

  List<String> _getSiblings(String memberId) {
    final parents =
        relations
            .where((r) => r.toId == memberId && r.type == RelationType.child)
            .map((r) => r.fromId)
            .toList();

    final siblings = <String>{};
    for (final parentId in parents) {
      final children = _getChildren(parentId);
      siblings.addAll(children.where((id) => id != memberId));
    }
    return siblings.toList();
  }

  List<String> _getBrothers(String memberId) {
    return _getSiblings(
      memberId,
    ).where((id) => members[id]?.gender == Gender.male).toList();
  }

  List<String> _getSisters(String memberId) {
    return _getSiblings(
      memberId,
    ).where((id) => members[id]?.gender == Gender.female).toList();
  }

  String? _getPaternGrandfather(String memberId) {
    final father = _getAyah(memberId);
    return father != null ? _getAyah(father) : null;
  }

  String? _getMaternalGrandmother(String memberId) {
    final mother = _getIbu(memberId);
    return mother != null ? _getIbu(mother) : null;
  }

  String? _getPaternalGrandmother(String memberId) {
    final father = _getAyah(memberId);
    return father != null ? _getIbu(father) : null;
  }
}
