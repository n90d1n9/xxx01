// services/faraid_service.dart
import '../models/family_member.dart';
import '../models/faraid_model.dart';
import '../models/relation_type.dart';
import 'faraid_calculator.dart';
import 'hanafi_calculator.dart';
import 'hanbali_calculator.dart';
import 'maliki_calculator.dart';
import 'shafii_calculator.dart';

class FaraidService {
  FaraidResult calculate(InheritanceCase inheritanceCase) {
    final calculator = _getCalculator(inheritanceCase.method);
    return calculator.calculate(inheritanceCase);
  }

  FaraidCalculator _getCalculator(CalculationMethod method) {
    return switch (method) {
      CalculationMethod.sunniHanafi => SunniHanafiCalculator(),
      CalculationMethod.sunniShafi => SunniShafiCalculator(),
      CalculationMethod.maliki => MalikiCalculator(),
      CalculationMethod.hanbali => HanbaliCalculator(),
    };
  }

  // Helper method to create inheritance case from your existing data structure
  InheritanceCase createInheritanceCase({
    required List<FamilyMember> members,
    required CalculationMethod method,
  }) {
    final deceased =
        members.firstWhere((m) => m.relation == RelationType.deceased);
    final heirs = members
        .where((m) => m.relation != RelationType.deceased && !m.isDeceased)
        .toList();

    return InheritanceCase(
      heirs: heirs
          .map((member) => Heir(
                id: member.id,
                name: member.name,
                gender: member.gender,
                relation: member.relation,
                isDeceased: member.isDeceased,
              ))
          .toList(),
      deceasedGender: deceased.gender,
      method: method,
    );
  }
}
