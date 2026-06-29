import 'package:flutter/material.dart';

import 'relation_type.dart';

enum Gender { male, female }

class FamilyMember {
  final String id;
  final String name;
  final RelationType relation;
  final Gender gender;
  final bool isDeceased;
  final String? parentId;
  final int age;
  final String? notes;
  double faraidShare;
  Offset position;

  final String? photoPath;

  String? calculationReason;
  final Map<String, dynamic> extraData;

  // Helper methods for mahram data
  bool get isMilkMother => extraData['isMilkMother'] ?? false;
  bool get isMilkChild => extraData['isMilkChild'] ?? false;
  bool get isMilkSibling => extraData['isMilkSibling'] ?? false;
  bool get isMotherInLaw => extraData['isMotherInLaw'] ?? false;
  bool get isStepDaughter => extraData['isStepDaughter'] ?? false;

  // For complex sibling relationships
  bool get maternal => extraData['maternal'] ?? true;
  bool get paternal => extraData['paternal'] ?? true;

  // For grandchildren cases
  String? get fatherId => extraData['fatherId'];
  String? get motherId => extraData['motherId'];
  String? get grandFatherId => extraData['grandFatherId'];
  String? get grandMotherId => extraData['grandMotherId'];

  // For religious cases
  String get religion => extraData['religion'] ?? 'Islam';

  // For pregnancy cases
  bool get isPregnant => extraData['isPregnant'] ?? false;

  // For missing persons
  bool get isMissing => extraData['isMissing'] ?? false;
  DateTime? get missingSince => extraData['missingSince'];

  // For illegitimate children
  bool get isIllegitimate => extraData['isIllegitimate'] ?? false;

  // For transgender cases
  bool get isTransgender => extraData['isTransgender'] ?? false;
  Gender get birthGender => extraData['birthGender'] ?? gender;

  // For adoption cases
  bool get isAdopted => extraData['isAdopted'] ?? false;
  bool get isAdoptiveParent => extraData['isAdoptiveParent'] ?? false;
  String? get adoptiveParentId => extraData['adoptiveParentId'];

  // For death circumstances
  DateTime get deathDate => extraData['deathDate'] ?? DateTime.now();

  // For polygamy cases
  int get wivesCount => extraData['wivesCount'] ?? 1;

  // For divorce cases
  bool get isDivorced => extraData['isDivorced'] ?? false;
  String get divorceType => extraData['divorceType'] ?? '';
  int get divorceCount => extraData['divorceCount'] ?? 0;
  bool get wasMarriedToFather => extraData['wasMarriedToFather'] ?? false;
  bool get wasDaughterInLaw => extraData['wasDaughterInLaw'] ?? false;
  bool get marriageConsumated => extraData['marriageConsumated'] ?? false;
  String? get exHusbandId => extraData['exHusbandId'];
  List<String> get exHusbands => extraData['exHusbands'] ?? [];

  // Helper methods
  bool isSiblingOf(String? parentId) {
    // Implementation for checking sibling relationship
    return extraData['parentId'] == parentId;
  }

  bool isPaternalUncleOf(FamilyMember niece) {
    // Implementation for checking paternal uncle relationship
    return extraData['isPaternal'] == true &&
        niece.extraData['grandFatherId'] == extraData['fatherId'];
  }

  // Helper methods for complex relationships
  bool isUterineSiblingOf(FamilyMember sibling) {
    return maternal == true &&
        paternal == false &&
        sibling.maternal == true &&
        sibling.paternal == false &&
        motherId == sibling.motherId;
  }

  bool isConsanguineSiblingOf(FamilyMember sibling) {
    return maternal == false &&
        paternal == true &&
        sibling.maternal == false &&
        sibling.paternal == true &&
        fatherId == sibling.fatherId;
  }

  // Set mahram-related data
  FamilyMember withMilkRelationship(bool isMilkMother, bool isMilkChild) {
    return copyWith(
      extraData: {
        ...extraData,
        'isMilkMother': isMilkMother,
        'isMilkChild': isMilkChild,
      },
    );
  }

  FamilyMember withFamilyRelationship(bool isMotherInLaw, bool isStepDaughter) {
    return copyWith(
      extraData: {
        ...extraData,
        'isMotherInLaw': isMotherInLaw,
        'isStepDaughter': isStepDaughter,
      },
    );
  }

  Map<String, dynamic> toFactMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation, // This is the enum object
      'relationName':
          relation
              .toString()
              .split('.')
              .last, // This should be "deceased", "son", etc.
      'gender': gender, // This is the enum object
      'genderName':
          gender.toString().split('.').last, // This should be "male", "female"
      'isDeceased': isDeceased,
      'faraidShare': faraidShare,
      'calculationReason': calculationReason,
      'maternal': relation.toString().contains('maternal'),
      'paternal': relation.toString().contains('paternal'),
      'isDeceasedPerson':
          relation == RelationType.deceased, // Mark deceased person correctly
      // Add any additional fields your YAML rules might need
      'age': age,
      'isPregnant': isPregnant,
      'religion': religion,
    };
  }

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.gender,
    this.isDeceased = false,
    this.parentId,
    this.age = 0,
    this.notes,
    this.faraidShare = 0.0,
    Offset? position,
    this.photoPath,
    this.calculationReason,
    this.extraData = const {},
  }) : position = position ?? Offset.zero;

  FamilyMember copyWith({
    String? name,
    RelationType? relation,
    Gender? gender,
    bool? isDeceased,
    String? parentId,
    int? age,
    String? notes,
    double? faraidShare,
    Offset? position,
    String? photoPath,
    String? calculationReason,
    Map<String, dynamic>? extraData,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      gender: gender ?? this.gender,
      isDeceased: isDeceased ?? this.isDeceased,
      parentId: parentId ?? this.parentId,
      age: age ?? this.age,
      notes: notes ?? this.notes,
      faraidShare: faraidShare ?? this.faraidShare,
      position: position ?? this.position,
      photoPath: photoPath ?? this.photoPath,
      calculationReason: calculationReason ?? this.calculationReason,
      extraData: extraData ?? this.extraData,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'relation': relation.index,
    'gender': gender.index,
    'isDeceased': isDeceased,
    'parentId': parentId,
    'age': age,
    'notes': notes,
    'faraidShare': faraidShare,
    'positionX': position.dx,
    'positionY': position.dy,
    'photoPath': photoPath,
    'calculationReason': calculationReason,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'],
    name: json['name'],
    relation: RelationType.values[json['relation']],
    gender: Gender.values[json['gender']],
    isDeceased: json['isDeceased'] ?? false,
    parentId: json['parentId'],
    age: json['age'] ?? 0,
    notes: json['notes'],
    faraidShare: json['faraidShare'] ?? 0.0,
    position: Offset(json['positionX'] ?? 0, json['positionY'] ?? 0),
    photoPath: json['photoPath'],
    calculationReason: json['calculationReason'],
  );
}
