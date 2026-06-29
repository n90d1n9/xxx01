// models/mahram_relationships.dart
import 'package:collection/collection.dart';

import 'family_member.dart';
import 'relation_type.dart';

class MahramRelationship {
  final String fromMemberId;
  final String toMemberId;
  final MahramType type;
  final String explanation;
  final bool isPermanent;

  const MahramRelationship({
    required this.fromMemberId,
    required this.toMemberId,
    required this.type,
    required this.explanation,
    this.isPermanent = true,
  });
}

enum MahramType {
  bloodRelationship, // Nasab
  marriageRelationship, // Musaharah
  breastfeeding, // Rada'ah
  specificProhibition, // Mahram khusus
}

class MahramRules {
  static List<MahramRelationship> analyzeRelationships(
    List<FamilyMember> members,
  ) {
    final relationships = <MahramRelationship>[];
    final deceased = members.firstWhereOrNull(
      (m) => m.relation == RelationType.deceased,
    );

    if (deceased == null) return relationships;

    for (final member1 in members) {
      for (final member2 in members) {
        if (member1.id != member2.id &&
            !member1.isDeceased &&
            !member2.isDeceased) {
          final relationship = _getMahramRelationship(
            member1,
            member2,
            members,
          );
          if (relationship != null) {
            relationships.add(relationship);
          }
        }
      }
    }

    return relationships;
  }

  static MahramRelationship? _getMahramRelationship(
    FamilyMember member1,
    FamilyMember member2,
    List<FamilyMember> allMembers,
  ) {
    // Blood relationships (Nasab)
    if (_isBloodMahram(member1, member2, allMembers)) {
      return MahramRelationship(
        fromMemberId: member1.id,
        toMemberId: member2.id,
        type: MahramType.bloodRelationship,
        explanation: _getBloodRelationshipExplanation(member1, member2),
      );
    }

    // Marriage relationships (Musaharah)
    if (_isMarriageMahram(member1, member2, allMembers)) {
      return MahramRelationship(
        fromMemberId: member1.id,
        toMemberId: member2.id,
        type: MahramType.marriageRelationship,
        explanation: _getMarriageRelationshipExplanation(
          member1,
          member2,
          allMembers,
        ),
      );
    }

    return null;
  }

  static bool _isBloodMahram(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    // Direct ascending/descending relationships
    if (_isDirectAncestor(a, b) || _isDirectAncestor(b, a)) {
      return true;
    }

    // Siblings
    if (_areSiblings(a, b, allMembers)) {
      return true;
    }

    // Uncle/Aunt with Niece/Nephew
    if (_isUncleNieceRelationship(a, b, allMembers)) {
      return true;
    }

    return false;
  }

  static bool _isDirectAncestor(
    FamilyMember potentialAncestor,
    FamilyMember descendant,
  ) {
    // Father/Mother -> Son/Daughter
    if (potentialAncestor.relation == RelationType.father &&
        (descendant.relation == RelationType.son ||
            descendant.relation == RelationType.daughter)) {
      return true;
    }

    if (potentialAncestor.relation == RelationType.mother &&
        (descendant.relation == RelationType.son ||
            descendant.relation == RelationType.daughter)) {
      return true;
    }

    // Grandparent -> Grandchild relationships
    if ((potentialAncestor.relation == RelationType.paternalGrandfather ||
            potentialAncestor.relation == RelationType.paternalGrandmother ||
            potentialAncestor.relation == RelationType.maternalGrandfather ||
            potentialAncestor.relation == RelationType.maternalGrandmother) &&
        (descendant.relation == RelationType.son ||
            descendant.relation == RelationType.daughter)) {
      return true;
    }

    return false;
  }

  static bool _areSiblings(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    // Both are children of the same deceased
    if ((a.relation == RelationType.son ||
            a.relation == RelationType.daughter) &&
        (b.relation == RelationType.son ||
            b.relation == RelationType.daughter)) {
      return true;
    }

    // Both are brothers/sisters
    if ((a.relation == RelationType.brother ||
            a.relation == RelationType.sister) &&
        (b.relation == RelationType.brother ||
            b.relation == RelationType.sister)) {
      return true;
    }

    return false;
  }

  static bool _isUncleNieceRelationship(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    // This is a simplified check - in real implementation, you'd track parent relationships
    if ((a.relation == RelationType.brother &&
            (b.relation == RelationType.son ||
                b.relation == RelationType.daughter)) ||
        (b.relation == RelationType.brother &&
            (a.relation == RelationType.son ||
                a.relation == RelationType.daughter))) {
      return true;
    }

    return false;
  }

  static bool _isMarriageMahram(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    // Father/Mother-in-law relationships
    if (_isInLawRelationship(a, b, allMembers)) {
      return true;
    }

    // Step-parent/step-child relationships
    if (_isStepRelationship(a, b, allMembers)) {
      return true;
    }

    return false;
  }

  static bool _isInLawRelationship(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    final spouses =
        allMembers.where((m) => m.relation == RelationType.spouse).toList();

    for (final spouse in spouses) {
      // If A is spouse of B's child
      if (spouse.id == a.id) {
        final potentialChild = b;
        if (potentialChild.relation == RelationType.son ||
            potentialChild.relation == RelationType.daughter) {
          return true;
        }
      }
    }

    return false;
  }

  static bool _isStepRelationship(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    // Simplified step-relationship check
    // In full implementation, you'd track marriage and parent relationships
    return false;
  }

  static String _getBloodRelationshipExplanation(
    FamilyMember a,
    FamilyMember b,
  ) {
    if (_isDirectAncestor(a, b)) {
      return 'Hubungan nasab: ${_getRelationLabel(a.relation)} dengan ${_getRelationLabel(b.relation)}';
    } else if (_areSiblings(a, b, [])) {
      return 'Hubungan saudara kandung';
    } else if (_isUncleNieceRelationship(a, b, [])) {
      return 'Hubungan paman/keponakan';
    }

    return 'Hubungan mahram nasab';
  }

  static String _getMarriageRelationshipExplanation(
    FamilyMember a,
    FamilyMember b,
    List<FamilyMember> allMembers,
  ) {
    if (_isInLawRelationship(a, b, allMembers)) {
      return 'Hubungan mahram karena pernikahan (musaharah)';
    }

    return 'Hubungan mahram pernikahan';
  }

  static String _getRelationLabel(RelationType relation) {
    const labels = {
      RelationType.deceased: 'Almarhum',
      RelationType.father: 'Ayah',
      RelationType.mother: 'Ibu',
      RelationType.spouse: 'Pasangan',
      RelationType.son: 'Anak Laki-laki',
      RelationType.daughter: 'Anak Perempuan',
      RelationType.brother: 'Saudara Laki-laki',
      RelationType.sister: 'Saudara Perempuan',
      RelationType.paternalGrandfather: 'Kakek Paternal',
      RelationType.paternalGrandmother: 'Nenek Paternal',
      RelationType.maternalGrandfather: 'Kakek Maternal',
      RelationType.maternalGrandmother: 'Nenek Maternal',
    };
    return labels[relation] ?? relation.toString().split('.').last;
  }
}
