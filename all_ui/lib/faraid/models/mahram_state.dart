import 'mahram_relationship.dart';

class MahramState {
  final List<MahramRelationship> relationships;
  final List<String> forbiddenMarriages;
  final List<String> validationErrors;
  final List<String> recommendations;
  final bool isLoading;
  final bool hasErrors;
  final String calculationMethod;

  MahramState({
    this.relationships = const [],
    this.forbiddenMarriages = const [],
    this.validationErrors = const [],
    this.recommendations = const [],
    this.isLoading = false,
    this.hasErrors = false,
    this.calculationMethod = 'Syafii',
  });

  MahramState copyWith({
    List<MahramRelationship>? relationships,
    List<String>? forbiddenMarriages,
    List<String>? validationErrors,
    List<String>? recommendations,
    bool? isLoading,
    bool? hasErrors,
    String? calculationMethod,
  }) {
    return MahramState(
      relationships: relationships ?? this.relationships,
      forbiddenMarriages: forbiddenMarriages ?? this.forbiddenMarriages,
      validationErrors: validationErrors ?? this.validationErrors,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      hasErrors: hasErrors ?? this.hasErrors,
      calculationMethod: calculationMethod ?? this.calculationMethod,
    );
  }
}
