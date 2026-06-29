// Mahram State
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/family_member.dart';
import '../models/mahram_relationship.dart';
import '../models/mahram_state.dart';
import '../models/mahram_validation_result.dart';
import '../services/mahram_rule_engine.dart';

// Mahram Notifier
class MahramNotifier extends StateNotifier<MahramState> {
  final MahramDrlEngine _mahramEngine = MahramDrlEngine();

  MahramNotifier() : super(MahramState());

  Future<void> validateFamilyRelationships(List<FamilyMember> members) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _mahramEngine.validateRelationships(
        members: members,
        method: state.calculationMethod,
      );

      state = state.copyWith(
        isLoading: false,
        relationships: result.mahramRelationships,
        forbiddenMarriages: result.forbiddenMarriages,
        validationErrors: result.validationErrors,
        recommendations: result.recommendations,
        hasErrors: result.hasCriticalErrors,
      );

      // Log results
      _logValidationResults(result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasErrors: true,
        validationErrors: ['Error dalam validasi mahram: $e'],
      );
    }
  }

  void setCalculationMethod(String method) {
    state = state.copyWith(calculationMethod: method);
  }

  void clearResults() {
    state = MahramState(calculationMethod: state.calculationMethod);
  }

  void _logValidationResults(MahramValidationResult result) {
    print('=== HASIL VALIDASI MAHRAM ===');
    print('Metode: ${state.calculationMethod}');
    print('Hubungan Mahram: ${result.mahramRelationships.length}');
    print('Pernikahan Terlarang: ${result.forbiddenMarriages.length}');
    print('Error Validasi: ${result.validationErrors.length}');

    for (final error in result.validationErrors) {
      print('⚠️  $error');
    }

    for (final marriage in result.forbiddenMarriages) {
      print('🚫 $marriage');
    }
  }

  // Helper method to check if two members are mahram
  bool areMahram(String person1Id, String person2Id) {
    return state.relationships.any(
      (rel) =>
          (rel.person1Id == person1Id && rel.person2Id == person2Id) ||
          (rel.person1Id == person2Id && rel.person2Id == person1Id),
    );
  }

  // Get mahram relationships for a specific person
  List<MahramRelationship> getMahramForPerson(String personId) {
    return state.relationships
        .where((rel) => rel.person1Id == personId || rel.person2Id == personId)
        .toList();
  }
}

// Riverpod Providers
final mahramProvider = StateNotifierProvider<MahramNotifier, MahramState>((
  ref,
) {
  return MahramNotifier();
});

final mahramRelationshipsProvider = Provider<List<MahramRelationship>>((ref) {
  return ref.watch(mahramProvider).relationships;
});

final mahramValidationErrorsProvider = Provider<List<String>>((ref) {
  return ref.watch(mahramProvider).validationErrors;
});

final hasCriticalMahramErrorsProvider = Provider<bool>((ref) {
  return ref.watch(mahramProvider).hasErrors;
});
