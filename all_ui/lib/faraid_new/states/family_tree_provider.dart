import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/assets.dart';
import '../models/estate.dart';
import '../models/family_member.dart';
import '../models/family_tree_state.dart';
import '../models/faraid_model.dart';
import '../models/relation_type.dart';
import '../services/faraid_service.dart';

class FamilyTreeNotifier extends StateNotifier<FamilyTreeState> {
  FamilyTreeNotifier() : super(FamilyTreeState());
  final FaraidService _faraidService = FaraidService();
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

  void _calculateFaraid() {
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

    try {
      final inheritanceCase = _faraidService.createInheritanceCase(
        members: state.members,
        method: _parseCalculationMethod(state.calculationMethod),
      );

      final result = _faraidService.calculate(inheritanceCase);

      // Apply results to state
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
                calculationReason: 'Tidak mendapatkan bagian',
              ),
        ],
      );

      // Log calculation details
      print('=== FARAID CALCULATION COMPLETE ===');
      print('Method: ${state.calculationMethod}');
      print('Shares: ${result.shares}');
      print('Remaining: ${result.remainingShare}');
      print('Steps:');
      result.calculationSteps.forEach(print);
    } catch (e) {
      print('Error in Faraid calculation: $e');
      // Fallback to your original manual calculation if needed
      _calculateFaraidManual();
    }
  }

  CalculationMethod _parseCalculationMethod(String methodName) {
    return switch (methodName.toLowerCase()) {
      'shafi' => CalculationMethod.sunniShafi,
      'maliki' => CalculationMethod.maliki,
      'hanbali' => CalculationMethod.hanbali,
      _ => CalculationMethod.sunniHanafi, // default
    };
  }

  void _calculateFaraidManual() {
    for (var member in state.members) {
      member.faraidShare = 0.0;
      member.calculationReason = null;
    }

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

    final spouses =
        heirs.where((m) => m.relation == RelationType.spouse).toList();
    final parents =
        heirs
            .where(
              (m) =>
                  m.relation == RelationType.father ||
                  m.relation == RelationType.mother,
            )
            .toList();
    final children =
        heirs
            .where(
              (m) =>
                  m.relation == RelationType.son ||
                  m.relation == RelationType.daughter,
            )
            .toList();
    final siblings =
        heirs
            .where(
              (m) =>
                  m.relation == RelationType.brother ||
                  m.relation == RelationType.sister,
            )
            .toList();

    double totalShares = 0.0;
    Map<String, double> shares = {};
    Map<String, String> reasons = {};

    for (var spouse in spouses) {
      if (children.isNotEmpty) {
        shares[spouse.id] = deceased.gender == Gender.male ? 0.125 : 0.25;
        reasons[spouse.id] =
            deceased.gender == Gender.male
                ? 'Pasangan mendapatkan 1/8 (12.5%) pada saat almarhum memiliki anak (Quran 4:12)'
                : 'Pasangan mendapatkan 1/4 (25%) pada saat almarhum memiliki anak (Quran 4:12)';
      } else {
        shares[spouse.id] = deceased.gender == Gender.male ? 0.25 : 0.5;
        reasons[spouse.id] =
            deceased.gender == Gender.male
                ? 'Pasangan mendapatkan 1/4 (25%) pada saat almarhum tidak memiliki anak (Quran 4:12)'
                : 'Pasangan mendapatkan 1/2 (50%) pada saat almarhum tidak memiliki anak (Quran 4:12)';
      }
      totalShares += shares[spouse.id]!;
    }

    final father =
        parents.where((p) => p.relation == RelationType.father).firstOrNull;
    final mother =
        parents.where((p) => p.relation == RelationType.mother).firstOrNull;

    if (mother != null) {
      if (children.isNotEmpty || siblings.length >= 2) {
        shares[mother.id] = 1.0 / 6.0;
        reasons[mother.id] =
            'Ibu mendapatkan 1/6 (16.67%) pada saat almarhum memiliki anak atau memiliki banyak saudara (Quran 4:11)';
      } else {
        shares[mother.id] = 1.0 / 3.0;
        reasons[mother.id] =
            'Ibu mendapatkan 1/3 (33.33%) ketika tidak memiliki anak atau memiliki saudara (Quran 4:11)';
      }
      totalShares += shares[mother.id]!;
    }

    if (father != null) {
      if (children.isNotEmpty) {
        shares[father.id] = 1.0 / 6.0;
        reasons[father.id] =
            'Ayah mendapatkan 1/6 (16.67%) pada saat almarhum memiliki anak (Quran 4:11)';
        totalShares += shares[father.id]!;
      }
    }

    if (children.isNotEmpty) {
      final sons = children.where((c) => c.gender == Gender.male).length;
      final daughters = children.where((c) => c.gender == Gender.female).length;
      final remainingShare = 1.0 - totalShares;
      final totalUnits = (sons * 2) + daughters;

      if (totalUnits > 0) {
        final unitValue = remainingShare / totalUnits;
        for (var child in children) {
          shares[child.id] =
              child.gender == Gender.male ? unitValue * 2 : unitValue;
          reasons[child.id] =
              child.gender == Gender.male
                  ? 'Anak Laki-laki mendapatkan rasio 2:1 dengan laki-laki:perempuan (Quran 4:11)'
                  : 'Anak Perempuan mendapatkan rasio 1:2 dengan laki-laki:perempuan (Quran 4:11)';
        }
      }
    } else if (siblings.isNotEmpty && father == null) {
      final brothers = siblings.where((s) => s.gender == Gender.male).length;
      final sisters = siblings.where((s) => s.gender == Gender.female).length;
      final remainingShare = 1.0 - totalShares;
      final totalUnits = (brothers * 2) + sisters;

      if (totalUnits > 0) {
        final unitValue = remainingShare / totalUnits;
        for (var sibling in siblings) {
          shares[sibling.id] =
              sibling.gender == Gender.male ? unitValue * 2 : unitValue;
          reasons[sibling.id] =
              sibling.gender == Gender.male
                  ? 'Saudara laki-laki mendapatkan rasio 2:1 dengan laki-laki:perempuan (Quran 4:176)'
                  : 'Saudara perempuan mendapatkan rasio 1:2 dengan laki-laki:perempuan (Quran 4:176)';
        }
      }
    } else if (father != null && children.isEmpty) {
      final remainingShare = 1.0 - totalShares;
      shares[father.id] = (shares[father.id] ?? 0.0) + remainingShare;
      reasons[father.id] =
          'Ayah mendapatkan 1/6 sebagai \'asabah ketika tidak memiliki anak  (Quran 4:11)';
    }

    state = state.copyWith(
      members: [
        for (final m in state.members)
          if (shares.containsKey(m.id))
            m.copyWith(
              faraidShare: shares[m.id],
              calculationReason: reasons[m.id],
            )
          else
            m,
      ],
    );
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
