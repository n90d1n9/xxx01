// State Management
import 'estate.dart';
import 'family_member.dart';

class FamilyTreeState {
  final List<FamilyMember> members;
  final Estate estate;
  final String? selectedMemberId;
  final bool showGrid;
  final double scale;
  final String calculationMethod;

  FamilyTreeState({
    this.members = const [],
    Estate? estate,
    this.selectedMemberId,
    this.showGrid = true,
    this.scale = 1.0,
    this.calculationMethod = 'Hanafi',
  }) : estate = estate ?? Estate();

  FamilyTreeState copyWith({
    List<FamilyMember>? members,
    Estate? estate,
    String? selectedMemberId,
    bool? clearSelection,
    bool? showGrid,
    double? scale,
    String? calculationMethod,
  }) {
    return FamilyTreeState(
      members: members ?? this.members,
      estate: estate ?? this.estate,
      selectedMemberId:
          clearSelection == true
              ? null
              : (selectedMemberId ?? this.selectedMemberId),
      showGrid: showGrid ?? this.showGrid,
      scale: scale ?? this.scale,
      calculationMethod: calculationMethod ?? this.calculationMethod,
    );
  }
}
