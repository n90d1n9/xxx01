// Mahram-specific data models
import '../models/family_member.dart';
import '../models/mahram_relationship.dart';
import '../models/mahram_validation_result.dart';
import 'engine.dart';
import 'utils.dart';

// Mahram Service using DRL
class MahramDrlEngine {
  final RuleEngine _engine = RuleEngine();

  MahramDrlEngine() {
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    // Load Mahram DRL rules
    final drlContent = await loadDrlFile('assets/rules/mahram_rules.drl');
    final rules = DrlParser.parse(drlContent);

    _engine.addRules(rules);

    // Initialize globals
    _engine.setGlobal('mahramRelationships', []);
    _engine.setGlobal('forbiddenMarriages', []);
    _engine.setGlobal('validationErrors', []);
    _engine.setGlobal('calculationMethod', 'Syafii');
    _engine.setGlobal('executionLog', []);
  }

  List<String> get extendedAgendaGroups => [
    'mahram-nasab',
    'mahram-susuan',
    'mahram-perkawinan',
    'polygamy-cases', // NEW
    'divorce-cases', // NEW
    'adoption-cases', // NEW
    'extended-family', // NEW
    'special-cases',
    'validation',
    'school-specific',
    'recommendations',
    'reporting',
    'completion',
  ];

  Future<MahramValidationResult> validateRelationships({
    required List<FamilyMember> members,
    String method = 'Syafii',
  }) async {
    _engine.clearFacts();
    _engine.setGlobal('mahramRelationships', []);
    _engine.setGlobal('forbiddenMarriages', []);
    _engine.setGlobal('validationErrors', []);
    _engine.setGlobal('executionLog', []);
    _engine.setGlobal('calculationMethod', method);

    // Insert all family members as facts
    for (final member in members) {
      _engine.insert(Fact('member', _createMemberFact(member)));
    }

    // Execute rules in order
    final agendaGroups = [
      'mahram-nasab',
      'mahram-susuan',
      'mahram-perkawinan',
      'special-cases',
      'validation',
      'school-specific',
      'recommendations',
      'reporting',
      'completion',
    ];

    for (final group in agendaGroups) {
      _engine.setFocus(group);
      _engine.fireUntilHalt(() => false);
    }

    // Collect results
    final mahramList = _engine.getGlobal('mahramRelationships') as List<String>;
    final forbiddenList =
        _engine.getGlobal('forbiddenMarriages') as List<String>;
    final errorList = _engine.getGlobal('validationErrors') as List<String>;
    final logList = _engine.getGlobal('executionLog') as List<String>;

    return MahramValidationResult(
      mahramRelationships: _parseMahramRelationships(mahramList, members),
      forbiddenMarriages: forbiddenList,
      validationErrors: errorList,
      recommendations: _generateRecommendations(mahramList, errorList),
      executionLog: logList,
      hasCriticalErrors: errorList.any(
        (error) => error.contains('PELANGGARAN BERAT'),
      ),
    );
  }

  List<MahramRelationship> _parseMahramRelationships(
    List<String> relationships,
    List<FamilyMember> members,
  ) {
    final result = <MahramRelationship>[];

    for (final rel in relationships) {
      final parts = rel.split(' adalah mahram bagi ');
      if (parts.length == 2) {
        final person1Name = parts[0];
        final person2WithDesc = parts[1];
        final person2Name = person2WithDesc.split(' (')[0];

        final person1 = members.firstWhere((m) => m.name == person1Name);
        final person2 = members.firstWhere((m) => m.name == person2Name);

        result.add(
          MahramRelationship(
            person1Id: person1.id,
            person2Id: person2.id,
            relationshipType: 'Mahram',
            description: rel,
            ruling: 'Hubungan mahram yang mengharamkan pernikahan',
            isForbidden: true,
            severity: _determineSeverity(rel),
          ),
        );
      }
    }

    return result;
  }

  String _determineSeverity(String relationship) {
    if (relationship.contains('ibu kandung') ||
        relationship.contains('anak kandung') ||
        relationship.contains('HARAM MUTLAK')) {
      return 'high';
    } else if (relationship.contains('saudara kandung')) {
      return 'high';
    }
    return 'medium';
  }

  List<String> _generateRecommendations(
    List<String> mahramList,
    List<String> errors,
  ) {
    final recommendations = <String>[];

    if (errors.isNotEmpty) {
      recommendations.add(
        'Perhatikan hubungan mahram yang terdeteksi untuk menghindari pernikahan yang haram',
      );
    }

    if (mahramList.length > 10) {
      recommendations.add(
        'Keluarga besar terdeteksi, pastikan memahami semua hubungan mahram',
      );
    }

    return recommendations;
  }

  Map<String, dynamic> _createMemberFact(FamilyMember member) {
    return {
      'id': member.id,
      'name': member.name,
      'gender': member.gender,
      'relation': member.relation,
      'age': member.age,
      'isDeceased': member.isDeceased,
      'isMilkMother': member.extraData?['isMilkMother'] ?? false,
      'isMilkChild': member.extraData?['isMilkChild'] ?? false,
      'isMilkSibling': member.extraData?['isMilkSibling'] ?? false,
      'isMilkFather': member.extraData?['isMilkFather'] ?? false,
      'milkRelationsCount': member.extraData?['milkRelationsCount'] ?? 0,
      'sharedMilkMother': member.extraData?['sharedMilkMother'] ?? false,
      'isMotherInLaw': member.extraData?['isMotherInLaw'] ?? false,
      'isSonInLaw': member.extraData?['isSonInLaw'] ?? false,
      'isStepDaughter': member.extraData?['isStepDaughter'] ?? false,
      'isStepFather': member.extraData?['isStepFather'] ?? false,
      'isDaughterInLaw': member.extraData?['isDaughterInLaw'] ?? false,
      'isFatherInLaw': member.extraData?['isFatherInLaw'] ?? false,
      'isStepMother': member.extraData?['isStepMother'] ?? false,
      'isStepSon': member.extraData?['isStepSon'] ?? false,
      'marriageToFatherConsumated':
          member.extraData?['marriageToFatherConsumated'] ?? false,
      'familyId': member.extraData?['familyId'] ?? 'default',
      'isMahram': member.extraData?['isMahram'] ?? false,
    };
  }
}
