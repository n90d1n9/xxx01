import 'family.dart';
import 'mahram_status.dart';

class FamilyState {
  final Map<String, FamilyMember> members;
  final List<FamilyRelation> relations;
  final String? selectedMemberId;
  final Map<String, InheritanceInfo>? inheritanceData;
  final String? deceasedMemberId;
  final List<FamilyTree> trees;
  final String? currentTreeId;
  final bool isLoading;
  final String? error;

  FamilyState({
    this.members = const {},
    this.relations = const [],
    this.selectedMemberId,
    this.inheritanceData,
    this.deceasedMemberId,
    this.trees = const [],
    this.currentTreeId,
    this.isLoading = false,
    this.error,
  });

  FamilyState copyWith({
    Map<String, FamilyMember>? members,
    List<FamilyRelation>? relations,
    String? selectedMemberId,
    Map<String, InheritanceInfo>? inheritanceData,
    String? deceasedMemberId,
    List<FamilyTree>? trees,
    String? currentTreeId,
    bool? isLoading,
    String? error,
    bool clearSelection = false,
    bool clearInheritance = false,
    bool clearDeceased = false,
    bool clearError = false,
  }) {
    return FamilyState(
      members: members ?? this.members,
      relations: relations ?? this.relations,
      selectedMemberId:
          clearSelection ? null : (selectedMemberId ?? this.selectedMemberId),
      inheritanceData:
          clearInheritance ? null : (inheritanceData ?? this.inheritanceData),
      deceasedMemberId:
          clearDeceased ? null : (deceasedMemberId ?? this.deceasedMemberId),
      trees: trees ?? this.trees,
      currentTreeId: currentTreeId ?? this.currentTreeId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
