import 'family_member.dart';
import 'relation_type.dart';

class FaraidFacts {
  static const String deceased = 'deceased';
  static const String heir = 'heir';
  static const String calculation = 'calculation';
  static const String estate = 'estate';
}

class FaraidRelations {
  static const List<RelationType> children = [
    RelationType.son,
    RelationType.daughter,
    RelationType.grandson,
    RelationType.granddaughter,
  ];

  static const List<RelationType> parents = [
    RelationType.father,
    RelationType.mother,
  ];

  static const List<RelationType> siblings = [
    RelationType.brother,
    RelationType.sister,
  ];

  static const List<RelationType> spouses = [RelationType.spouse];
}

class FaraidConstraints {
  static List<Constraint> hasRelation(RelationType relation) {
    return [Constraint('relation', Operator.equals, relation)];
  }

  static List<Constraint> hasGender(Gender gender) {
    return [Constraint('gender', Operator.equals, gender)];
  }

  static List<Constraint> isDeceased(bool deceased) {
    return [Constraint('isDeceased', Operator.equals, deceased)];
  }

  static Constraint relationEquals(RelationType relation) {
    return Constraint('relation', Operator.equals, relation);
  }

  static Constraint genderEquals(Gender gender) {
    return Constraint('gender', Operator.equals, gender);
  }
}

class FaraidResult {
  final Map<String, double> shares;
  final Map<String, String> reasons;
  final List<String> executedRules;
  final String? warning;
  final Map<String, dynamic> statistics;

  FaraidResult({
    required this.shares,
    required this.reasons,
    required this.executedRules,
    this.warning,
    required this.statistics,
  });
}
