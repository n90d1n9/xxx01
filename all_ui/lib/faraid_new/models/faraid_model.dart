import 'family_member.dart';
import 'relation_type.dart';

enum CalculationMethod {
  sunniHanafi('Sunni Hanafi', 'Standard Sunni Hanafi school'),
  sunniShafi('Sunni Shafi\'i', 'Sunni Shafi\'i school'),
  maliki('Maliki', 'Maliki school'),
  hanbali('Hanbali', 'Hanbali school');

  final String name;
  final String description;

  const CalculationMethod(this.name, this.description);
}

class Heir {
  final String id;
  final String name;
  final Gender gender;
  final RelationType relation;
  final bool isDeceased;

  const Heir({
    required this.id,
    required this.name,
    required this.gender,
    required this.relation,
    this.isDeceased = false,
  });
}

class InheritanceCase {
  final List<Heir> heirs;
  final Gender deceasedGender;
  final CalculationMethod method;

  const InheritanceCase({
    required this.heirs,
    required this.deceasedGender,
    required this.method,
  });

  List<Heir> get spouses =>
      heirs.where((h) => h.relation == RelationType.spouse).toList();
  List<Heir> get fathers =>
      heirs.where((h) => h.relation == RelationType.father).toList();
  List<Heir> get mothers =>
      heirs.where((h) => h.relation == RelationType.mother).toList();
  List<Heir> get sons =>
      heirs.where((h) => h.relation == RelationType.son).toList();
  List<Heir> get daughters =>
      heirs.where((h) => h.relation == RelationType.daughter).toList();
  List<Heir> get brothers =>
      heirs.where((h) => h.relation == RelationType.brother).toList();
  List<Heir> get sisters =>
      heirs.where((h) => h.relation == RelationType.sister).toList();

  bool get hasChildren => sons.isNotEmpty || daughters.isNotEmpty;
  bool get hasSiblings => brothers.isNotEmpty || sisters.isNotEmpty;
  bool get hasParents => fathers.isNotEmpty || mothers.isNotEmpty;
}

class FaraidResult {
  final Map<String, double> shares;
  final Map<String, String> reasons;
  final double remainingShare;
  final List<String> calculationSteps;

  const FaraidResult({
    required this.shares,
    required this.reasons,
    this.remainingShare = 0.0,
    this.calculationSteps = const [],
  });

  double get totalDistributed {
    return shares.values.fold(0.0, (sum, share) => sum + share);
  }

  FaraidResult copyWith({
    Map<String, double>? shares,
    Map<String, String>? reasons,
    double? remainingShare,
    List<String>? calculationSteps,
  }) {
    return FaraidResult(
      shares: shares ?? this.shares,
      reasons: reasons ?? this.reasons,
      remainingShare: remainingShare ?? this.remainingShare,
      calculationSteps: calculationSteps ?? this.calculationSteps,
    );
  }
}
