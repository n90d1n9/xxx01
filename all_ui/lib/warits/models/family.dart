import 'gender.dart';

class FamilyTree {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyTree({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FamilyTree.fromJson(Map<String, dynamic> json) => FamilyTree(
    id: json['id'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class FamilyMember {
  final String id;
  final String name;
  final Gender gender;
  final bool isDeceased;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? notes;
  final String? photoUrl;
  final String? occupation;
  final String? address;
  final String? phoneNumber;
  final String? email;

  FamilyMember({
    required this.id,
    required this.name,
    required this.gender,
    this.isDeceased = false,
    this.birthDate,
    this.deathDate,
    this.notes,
    this.photoUrl,
    this.occupation,
    this.address,
    this.phoneNumber,
    this.email,
  });

  FamilyMember copyWith({
    String? name,
    Gender? gender,
    bool? isDeceased,
    DateTime? birthDate,
    DateTime? deathDate,
    String? notes,
    String? photoUrl,
    String? occupation,
    String? address,
    String? phoneNumber,
    String? email,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      isDeceased: isDeceased ?? this.isDeceased,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  int? get age {
    if (birthDate == null) return null;
    final endDate =
        isDeceased && deathDate != null ? deathDate! : DateTime.now();
    return endDate.year - birthDate!.year;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'gender': gender.name,
    'isDeceased': isDeceased,
    'birthDate': birthDate?.toIso8601String(),
    'deathDate': deathDate?.toIso8601String(),
    'notes': notes,
    'photoUrl': photoUrl,
    'occupation': occupation,
    'address': address,
    'phoneNumber': phoneNumber,
    'email': email,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'],
    name: json['name'],
    gender: Gender.values.firstWhere((e) => e.name == json['gender']),
    isDeceased: json['isDeceased'] ?? false,
    birthDate:
        json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
    deathDate:
        json['deathDate'] != null ? DateTime.parse(json['deathDate']) : null,
    notes: json['notes'],
    photoUrl: json['photoUrl'],
    occupation: json['occupation'],
    address: json['address'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
  );
}

class FamilyRelation {
  final String fromId;
  final String toId;
  final RelationType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final MarriageStatus? marriageStatus;
  final String? notes;

  FamilyRelation({
    required this.fromId,
    required this.toId,
    required this.type,
    this.startDate,
    this.endDate,
    this.marriageStatus,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'fromId': fromId,
    'toId': toId,
    'type': type.name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'marriageStatus': marriageStatus?.name,
    'notes': notes,
  };

  factory FamilyRelation.fromJson(Map<String, dynamic> json) => FamilyRelation(
    fromId: json['fromId'],
    toId: json['toId'],
    type: RelationType.values.firstWhere((e) => e.name == json['type']),
    startDate:
        json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    marriageStatus:
        json['marriageStatus'] != null
            ? MarriageStatus.values.firstWhere(
              (e) => e.name == json['marriageStatus'],
            )
            : null,
    notes: json['notes'],
  );
}
