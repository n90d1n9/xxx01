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
