import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/assets.dart';
import '../models/estate.dart';
import '../models/family_member.dart';
import '../models/family_tree_state.dart';
import '../models/relation_type.dart';
import '../services/faraid_rule_engine_adapter.dart';
import '../services/generic_faraid_adapter.dart';

class FamilyTreeNotifier extends StateNotifier<FamilyTreeState> {
  //final FaraidRuleEngineAdapter _faraidEngine = FaraidRuleEngineAdapter();
  final GenericFaraidAdapter _faraidEngine = GenericFaraidAdapter();
  FamilyTreeNotifier() : super(FamilyTreeState());

  void addMember(FamilyMember member) {
    state = state.copyWith(members: [...state.members, member]);
    _calculateFaraid();
    _autoLayoutMembers();
  }

  void updateMember(String id, FamilyMember updatedMember) {
    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (member.id == id) updatedMember else member,
      ],
    );
    _calculateFaraid();
  }

  void removeMember(String id) {
    state = state.copyWith(
      members: state.members.where((member) => member.id != id).toList(),
    );
    _calculateFaraid();
  }

  void selectMember(String? id) {
    state = state.copyWith(selectedMemberId: id, clearSelection: id == null);
  }

  void updateMemberPosition(String id, Offset position) {
    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (member.id == id) member.copyWith(position: position) else member,
      ],
    );
  }

  void updateEstate(Estate estate) {
    state = state.copyWith(estate: estate);
    _calculateFaraid();
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void updateScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  void clearAll() {
    state = FamilyTreeState();
  }

  void autoLayout() => _autoLayoutMembers();

  void _autoLayoutMembers() {
    final deceased = state.members.firstWhere(
      (m) => m.relation == RelationType.deceased,
      orElse:
          () => FamilyMember(
            id: '',
            name: '',
            relation: RelationType.deceased,
            gender: Gender.male,
          ),
    );

    if (deceased.id.isEmpty) return;

    final Map<String, Offset> positions = {};
    const centerX = 500.0;
    const centerY = 300.0;

    positions[deceased.id] = const Offset(centerX, centerY);

    // Pasangans
    final spouses =
        state.members.where((m) => m.relation == RelationType.spouse).toList();
    for (int i = 0; i < spouses.length; i++) {
      positions[spouses[i].id] = Offset(centerX + 250 + (i * 200), centerY);
    }

    // Parents
    final parents =
        state.members
            .where(
              (m) =>
                  m.relation == RelationType.father ||
                  m.relation == RelationType.mother,
            )
            .toList();
    for (int i = 0; i < parents.length; i++) {
      positions[parents[i].id] = Offset(
        centerX - 100 + (i * 200),
        centerY - 200,
      );
    }

    // Children
    final children =
        state.members
            .where(
              (m) =>
                  m.relation == RelationType.son ||
                  m.relation == RelationType.daughter,
            )
            .toList();
    final childrenStartX = centerX - ((children.length - 1) * 100);
    for (int i = 0; i < children.length; i++) {
      positions[children[i].id] = Offset(
        childrenStartX + (i * 200),
        centerY + 200,
      );
    }

    // Siblings
    final siblings =
        state.members
            .where(
              (m) =>
                  m.relation == RelationType.brother ||
                  m.relation == RelationType.sister,
            )
            .toList();
    final siblingsStartX = centerX - ((siblings.length - 1) * 100);
    for (int i = 0; i < siblings.length; i++) {
      positions[siblings[i].id] = Offset(
        siblingsStartX + (i * 200),
        centerY + 400,
      );
    }

    // Grandparents
    final grandparents =
        state.members
            .where(
              (m) =>
                  m.relation == RelationType.paternalGrandfather ||
                  m.relation == RelationType.paternalGrandmother ||
                  m.relation == RelationType.maternalGrandfather ||
                  m.relation == RelationType.maternalGrandmother,
            )
            .toList();
    for (int i = 0; i < grandparents.length; i++) {
      positions[grandparents[i].id] = Offset(
        centerX - 200 + (i * 150),
        centerY - 400,
      );
    }

    state = state.copyWith(
      members: [
        for (final member in state.members)
          if (positions.containsKey(member.id))
            member.copyWith(position: positions[member.id])
          else
            member,
      ],
    );
  }

  void _calculateFaraid() async {
    final deceased = state.members.firstWhere(
      (m) => m.relation == RelationType.deceased,
      orElse:
          () => FamilyMember(
            id: '',
            name: '',
            relation: RelationType.deceased,
            gender: Gender.male,
          ),
    );

    if (deceased.id.isEmpty) return;

    final heirs =
        state.members
            .where((m) => m.relation != RelationType.deceased && !m.isDeceased)
            .toList();

    if (heirs.isEmpty) return;

    try {
      // Prepare data in the new format
      final heirsData = _prepareHeirsData(heirs);
      final estateData = _prepareEstateData(state.estate);

      // Use the new generic adapter
      final result = await _faraidEngine.calculate(
        method: state.calculationMethod.toLowerCase().replaceAll(' ', '_'),
        heirs: heirsData,
        estate: estateData,
      );

      // Apply results (same as before)
      state = state.copyWith(
        members: [
          for (final member in state.members)
            if (result.shares.containsKey(member.id))
              member.copyWith(
                faraidShare: result.shares[member.id]!,
                calculationReason: result.reasons[member.id],
              )
            else
              member.copyWith(
                faraidShare: 0.0,
                calculationReason:
                    result.reasons[member.id] ?? 'Tidak mendapatkan bagian',
              ),
        ],
      );

      print('=== FARAID CALCULATION COMPLETE ===');
      print('Method: ${state.calculationMethod}');
      print('Shares: ${result.shares}');
      print('Remaining: ${result.statistics['remainingShare']}');
    } catch (e) {
      print('Error in Faraid calculation: $e');
    }
  }

  Map<String, dynamic> _prepareHeirsData(List<FamilyMember> heirs) {
    final data = <String, dynamic>{};

    for (final heir in heirs) {
      final heirType = _getHeirType(heir);
      if (!data.containsKey(heirType)) {
        data[heirType] = [];
      }
      (data[heirType] as List).add({
        'id': heir.id,
        'name': heir.name,
        'gender': heir.gender.toString().split('.').last,
        'relation': heir.relation.toString().split('.').last,
      });
    }

    return data;
  }

  String _getHeirType(FamilyMember heir) {
    switch (heir.relation) {
      case RelationType.spouse:
        return heir.gender == Gender.female ? 'wife' : 'husband';
      case RelationType.son:
        return 'son';
      case RelationType.daughter:
        return 'daughter';
      case RelationType.father:
        return 'father';
      case RelationType.mother:
        return 'mother';
      default:
        return heir.relation.toString().split('.').last;
    }
  }

  Map<String, dynamic> _prepareEstateData(Estate estate) {
    return {
      'netValue': estate.netEstate,
      'totalAssets': estate.totalAssets,
      'totalDebts': estate.totalDebts,
      'totalExpenses': estate.totalExpenses,
      'assets': estate.assets.map((a) => a.toJson()).toList(),
      'debts': estate.debts.map((d) => d.toJson()).toList(),
      'expenses': estate.expenses.map((e) => e.toJson()).toList(),
      'bequests': estate.bequests.map((b) => b.toJson()).toList(),
    };
  }

  void setCalculationMethod(String method) {
    state = state.copyWith(calculationMethod: method);
    _calculateFaraid();
  }

  void addAsset(Asset asset) {
    final updatedAssets = [...state.estate.assets, asset];
    state = state.copyWith(
      estate: state.estate.copyWith(assets: updatedAssets),
    );
    _calculateFaraid();
  }

  // Add these methods to your FamilyTreeNotifier class
  void updateAsset(Asset updatedAsset) {
    state = state.copyWith(
      estate: state.estate.copyWith(
        assets:
            state.estate.assets
                .map(
                  (asset) => asset.id == updatedAsset.id ? updatedAsset : asset,
                )
                .toList(),
      ),
    );
    _calculateFaraid();
  }

  void removeAsset(String assetId) {
    state = state.copyWith(
      estate: state.estate.copyWith(
        assets:
            state.estate.assets.where((asset) => asset.id != assetId).toList(),
      ),
    );
    _calculateFaraid();
  }

  String exportToJson() {
    final data = {
      'members': state.members.map((m) => m.toJson()).toList(),
      'estate': {
        'totalAmount': state.estate.totalAssets,
        'debts': state.estate.debts,
        'expenses': state.estate.expenses,
        'bequests': state.estate.bequests,
      },
    };
    return jsonEncode(data);
  }

  void importFromJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr);
      final members =
          (data['members'] as List)
              .map((m) => FamilyMember.fromJson(m))
              .toList();

      // Handle legacy JSON format with totalAmount
      final estateData = data['estate'] ?? {};

      // Convert legacy format to new format
      final assets = _convertLegacyAssets(estateData);
      final debts = _convertLegacyDebts(estateData);
      final expenses = _convertLegacyExpenses(estateData);
      final bequests = _convertLegacyBequests(estateData);

      final estate = Estate(
        assets: assets,
        debts: debts,
        expenses: expenses,
        bequests: bequests,
      );

      state = FamilyTreeState(members: members, estate: estate);
      _calculateFaraid();
    } catch (e) {
      print('Error importing: $e');
    }
  }

  // Helper methods to convert legacy JSON format to new object format
  List<Asset> _convertLegacyAssets(Map<String, dynamic> estateData) {
    if (estateData['assets'] != null) {
      // New format with assets list
      return (estateData['assets'] as List)
          .map((a) => Asset.fromJson(a))
          .toList();
    } else if (estateData['totalAmount'] != null) {
      // Legacy format - create a single asset from totalAmount
      return [
        Asset(
          id: 'legacy_total',
          name: 'Total Harta Warisan',
          description: 'Diimpor dari data lama',
          value: (estateData['totalAmount'] as num).toDouble(),
          category: 'Lain-lain',
        ),
      ];
    }
    return [];
  }

  List<Debt> _convertLegacyDebts(Map<String, dynamic> estateData) {
    final debts = <Debt>[];

    if (estateData['debts'] != null) {
      if (estateData['debts'] is Map) {
        // Legacy format: Map<String, double>
        final debtMap = Map<String, double>.from(estateData['debts']);
        debtMap.forEach((description, amount) {
          debts.add(
            Debt(
              id: 'debt_${description.hashCode}',
              creditor: 'Kreditor',
              description: description,
              originalAmount: amount,
              remainingAmount: amount,
              dueDate: DateTime.now().add(const Duration(days: 30)),
            ),
          );
        });
      } else if (estateData['debts'] is List) {
        // New format: List<Debt>
        return (estateData['debts'] as List)
            .map((d) => Debt.fromJson(d))
            .toList();
      }
    }

    return debts;
  }

  List<Expense> _convertLegacyExpenses(Map<String, dynamic> estateData) {
    final expenses = <Expense>[];

    if (estateData['expenses'] != null) {
      if (estateData['expenses'] is Map) {
        // Legacy format: Map<String, double>
        final expenseMap = Map<String, double>.from(estateData['expenses']);
        expenseMap.forEach((description, amount) {
          expenses.add(
            Expense(
              id: 'expense_${description.hashCode}',
              category: 'Pengeluaran',
              description: description,
              amount: amount,
            ),
          );
        });
      } else if (estateData['expenses'] is List) {
        // New format: List<Expense>
        return (estateData['expenses'] as List)
            .map((e) => Expense.fromJson(e))
            .toList();
      }
    }

    // Add funeral expenses if present in legacy data
    if (estateData['funeralExpenses'] != null) {
      expenses.add(
        Expense(
          id: 'funeral_expense',
          category: 'Pemakaman',
          description: 'Biaya Pemakaman',
          amount: (estateData['funeralExpenses'] as num).toDouble(),
        ),
      );
    }

    return expenses;
  }

  List<Bequest> _convertLegacyBequests(Map<String, dynamic> estateData) {
    final bequests = <Bequest>[];

    if (estateData['bequests'] != null) {
      if (estateData['bequests'] is Map) {
        // Legacy format: Map<String, double>
        final bequestMap = Map<String, double>.from(estateData['bequests']);
        bequestMap.forEach((beneficiary, amount) {
          bequests.add(
            Bequest(
              id: 'bequest_${beneficiary.hashCode}',
              beneficiary: beneficiary,
              description: 'Wasiat untuk $beneficiary',
              amount: amount,
              relationship: 'Lainnya',
            ),
          );
        });
      } else if (estateData['bequests'] is List) {
        // New format: List<Bequest>
        return (estateData['bequests'] as List)
            .map((b) => Bequest.fromJson(b))
            .toList();
      }
    }

    return bequests;
  }

  // Add these methods to your FamilyTreeNotifier class
  void updateFuneralExpenses(double amount) {
    state = state.copyWith(
      estate: state.estate.copyWith(funeralExpenses: amount),
    );
    _calculateFaraid();
  }

  void updateAdministrativeCosts(double amount) {
    state = state.copyWith(
      estate: state.estate.copyWith(administrativeCosts: amount),
    );
    _calculateFaraid();
  }

  void addDebt(Debt debt) {
    final updatedDebts = [...state.estate.debts, debt];
    state = state.copyWith(estate: state.estate.copyWith(debts: updatedDebts));
    _calculateFaraid();
  }

  void addBequest(Bequest bequest) {
    final updatedBequests = [...state.estate.bequests, bequest];
    state = state.copyWith(
      estate: state.estate.copyWith(bequests: updatedBequests),
    );
    _calculateFaraid();
  }
}

final familyTreeProvider =
    StateNotifierProvider<FamilyTreeNotifier, FamilyTreeState>((ref) {
      return FamilyTreeNotifier();
    });
