import 'class_group.dart';
import 'enums.dart';
import 'teacher.dart';

class Subject {
  final int id; // Unique identifier for the subject
  final String code; // Subject code, min=3, max=10, required, unique
  final String name; // Subject name, min=3, max=100, required
  final String? description; // Subject description
  final int
  creditHours; // Credit hours for the subject, min=1, max=10, default=2
  final bool isActive; // Whether subject is currently offered, default=true
  final SubjectType subjectType; // Type of the subject
  final DifficultyLevel difficultyLevel; // Difficulty level of the subject
  final List<Teacher>
  teachers; // Teachers who teach the subject, manyToMany relationship
  final List<ClassGroup>
  classGroups; // Class groups associated with the subject, manyToMany relationship

  Subject({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.creditHours = 2,
    this.isActive = true,
    required this.subjectType,
    required this.difficultyLevel,
    this.teachers = const [],
    this.classGroups = const [],
  });

  Subject copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    int? creditHours,
    bool? isActive,
    SubjectType? subjectType,
    DifficultyLevel? difficultyLevel,
    List<Teacher>? teachers,
    List<ClassGroup>? classGroups,
  }) {
    return Subject(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      creditHours: creditHours ?? this.creditHours,
      isActive: isActive ?? this.isActive,
      subjectType: subjectType ?? this.subjectType,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      teachers: teachers ?? this.teachers,
      classGroups: classGroups ?? this.classGroups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'creditHours': creditHours,
      'isActive': isActive,
      'subjectType': subjectType.toString(),
      'difficultyLevel': difficultyLevel.toString(),
      'teachers': teachers.map((e) => e.toJson()).toList(),
      'classGroups': classGroups.map((e) => e.toJson()).toList(),
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      creditHours: json['creditHours'],
      isActive: json['isActive'],
      subjectType: SubjectType.values.firstWhere(
        (e) => e.toString() == json['subjectType'],
      ),
      difficultyLevel: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == json['difficultyLevel'],
      ),
      teachers:
          (json['teachers'] as List).map((e) => Teacher.fromJson(e)).toList(),
      classGroups:
          (json['classGroups'] as List)
              .map((e) => ClassGroup.fromJson(e))
              .toList(),
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, code: $code, name: $name, description: $description, creditHours: $creditHours, isActive: $isActive, subjectType: $subjectType, difficultyLevel: $difficultyLevel, teachers: $teachers, classGroups: $classGroups)';
  }
}
