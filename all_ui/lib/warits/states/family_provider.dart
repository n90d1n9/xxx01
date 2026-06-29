import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/family.dart';
import '../models/family_state.dart';
import '../models/gender.dart';
import '../models/mahram_status.dart';
import '../services/islamic_inheritence_calculator.dart';

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((
  ref,
) {
  return FamilyNotifier();
});

class FamilyNotifier extends StateNotifier<FamilyState> {
  FamilyNotifier() : super(FamilyState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final treesJson = prefs.getString('family_trees');
      final currentTreeId = prefs.getString('current_tree_id');

      if (treesJson != null) {
        final treesList = jsonDecode(treesJson) as List;
        final trees = treesList.map((t) => FamilyTree.fromJson(t)).toList();
        state = state.copyWith(trees: trees, currentTreeId: currentTreeId);

        if (currentTreeId != null) {
          await _loadTree(currentTreeId);
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load data: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treesJson = jsonEncode(state.trees.map((t) => t.toJson()).toList());
      await prefs.setString('family_trees', treesJson);

      if (state.currentTreeId != null) {
        await prefs.setString('current_tree_id', state.currentTreeId!);
        final membersJson = jsonEncode(
          state.members.values.map((m) => m.toJson()).toList(),
        );
        final relationsJson = jsonEncode(
          state.relations.map((r) => r.toJson()).toList(),
        );

        await prefs.setString(
          'tree_${state.currentTreeId}_members',
          membersJson,
        );
        await prefs.setString(
          'tree_${state.currentTreeId}_relations',
          relationsJson,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to save data: $e');
    }
  }

  Future<void> _loadTree(String treeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = prefs.getString('tree_${treeId}_members');
      final relationsJson = prefs.getString('tree_${treeId}_relations');

      if (membersJson != null && relationsJson != null) {
        final membersList = jsonDecode(membersJson) as List;
        final relationsList = jsonDecode(relationsJson) as List;

        final members = {
          for (var m in membersList.map((m) => FamilyMember.fromJson(m)))
            m.id: m,
        };
        final relations =
            relationsList.map((r) => FamilyRelation.fromJson(r)).toList();

        state = state.copyWith(
          members: members,
          relations: relations,
          currentTreeId: treeId,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load tree: $e');
    }
  }

  Future<void> createNewTree(String name) async {
    final tree = FamilyTree(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      trees: [...state.trees, tree],
      currentTreeId: tree.id,
      members: {},
      relations: [],
      clearSelection: true,
      clearInheritance: true,
    );

    await _saveToStorage();
  }

  Future<void> switchTree(String treeId) async {
    await _loadTree(treeId);
    state = state.copyWith(
      currentTreeId: treeId,
      clearSelection: true,
      clearInheritance: true,
    );
  }

  Future<void> deleteTree(String treeId) async {
    final newTrees = state.trees.where((t) => t.id != treeId).toList();
    String? newCurrentTreeId = state.currentTreeId;

    if (state.currentTreeId == treeId) {
      newCurrentTreeId = newTrees.isNotEmpty ? newTrees.first.id : null;
      if (newCurrentTreeId != null) {
        await _loadTree(newCurrentTreeId);
      } else {
        state = state.copyWith(members: {}, relations: []);
      }
    }

    state = state.copyWith(trees: newTrees, currentTreeId: newCurrentTreeId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tree_${treeId}_members');
    await prefs.remove('tree_${treeId}_relations');
    await _saveToStorage();
  }

  Future<void> addMember(FamilyMember member) async {
    state = state.copyWith(members: {...state.members, member.id: member});
    await _saveToStorage();
  }

  Future<void> updateMember(FamilyMember member) async {
    state = state.copyWith(members: {...state.members, member.id: member});
    await _saveToStorage();
  }

  Future<void> removeMember(String id) async {
    final newMembers = Map<String, FamilyMember>.from(state.members)
      ..remove(id);
    final newRelations =
        state.relations.where((r) => r.fromId != id && r.toId != id).toList();
    state = state.copyWith(members: newMembers, relations: newRelations);
    await _saveToStorage();
  }

  Future<void> addRelation(FamilyRelation relation) async {
    final exists = state.relations.any(
      (r) =>
          r.fromId == relation.fromId &&
          r.toId == relation.toId &&
          r.type == relation.type,
    );

    if (!exists) {
      state = state.copyWith(relations: [...state.relations, relation]);
      await _saveToStorage();
    }
  }

  Future<void> removeRelation(FamilyRelation relation) async {
    state = state.copyWith(
      relations:
          state.relations
              .where(
                (r) =>
                    !(r.fromId == relation.fromId &&
                        r.toId == relation.toId &&
                        r.type == relation.type),
              )
              .toList(),
    );
    await _saveToStorage();
  }

  void selectMember(String? id) {
    state = state.copyWith(
      selectedMemberId: id,
      clearSelection: id == null,
      clearInheritance: true,
    );
  }

  void setInheritanceData(
    Map<String, InheritanceInfo> data,
    String deceasedId,
  ) {
    state = state.copyWith(inheritanceData: data, deceasedMemberId: deceasedId);
  }

  void clearInheritanceData() {
    state = state.copyWith(clearInheritance: true, clearDeceased: true);
  }

  // Complete Mahram calculation with all Islamic rules
  MahramStatus checkMahramStatus(String memberId1, String memberId2) {
    final member1 = state.members[memberId1];
    final member2 = state.members[memberId2];

    if (member1 == null || member2 == null) {
      return MahramStatus(
        isMahram: false,
        reason: 'Member not found',
        relationshipPath: [],
      );
    }

    if (memberId1 == memberId2) {
      return MahramStatus(
        isMahram: true,
        reason: 'Same person',
        relationshipPath: [member1.name],
      );
    }

    // Only check mahram between opposite genders
    if (member1.gender == member2.gender) {
      return MahramStatus(
        isMahram: false,
        reason: 'Mahram rules apply only between opposite genders',
        relationshipPath: [],
      );
    }

    // 1. Check Nasab (Blood Relations)
    final nasabCheck = _checkNasabMahram(memberId1, memberId2);
    if (nasabCheck.isMahram) return nasabCheck;

    // 2. Check Musaharah (Relations through Marriage)
    final musaharahCheck = _checkMusaharahMahram(memberId1, memberId2);
    if (musaharahCheck.isMahram) return musaharahCheck;

    // 3. Check Radha'ah (Milk Relations) - would need additional data structure
    // For now, we'll note this category exists but isn't implemented

    return MahramStatus(
      isMahram: false,
      reason: 'No mahram relationship found. Marriage is permissible.',
      relationshipPath: [],
    );
  }

  MahramStatus _checkNasabMahram(String memberId1, String memberId2) {
    final member1 = state.members[memberId1]!;
    final member2 = state.members[memberId2]!;

    // Direct ancestors/descendants
    final ancestors1 = _getAncestors(memberId1);
    if (ancestors1.contains(memberId2)) {
      return MahramStatus(
        isMahram: true,
        reason: 'Direct ancestor (mother, grandmother, etc.)',
        relationshipPath: _findPath(memberId1, memberId2),
        category: 'Nasab - Usul (Ascendants)',
      );
    }

    final descendants1 = _getDescendants(memberId1);
    if (descendants1.contains(memberId2)) {
      return MahramStatus(
        isMahram: true,
        reason: 'Direct descendant (daughter, granddaughter, etc.)',
        relationshipPath: _findPath(memberId1, memberId2),
        category: 'Nasab - Furu\' (Descendants)',
      );
    }

    // Siblings
    final siblings1 = _getSiblings(memberId1);
    if (siblings1.contains(memberId2)) {
      return MahramStatus(
        isMahram: true,
        reason: 'Full or half sibling',
        relationshipPath: [member1.name, member2.name],
        category: 'Nasab - Hawashi (Collaterals)',
      );
    }

    // Nieces/nephews (children of siblings)
    for (final siblingId in siblings1) {
      final niblings = _getChildren(siblingId);
      if (niblings.contains(memberId2)) {
        return MahramStatus(
          isMahram: true,
          reason: 'Niece/nephew (child of sibling)',
          relationshipPath: _findPath(memberId1, memberId2),
          category: 'Nasab - Hawashi (Collaterals)',
        );
      }
    }

    // Aunts/uncles (siblings of parents)
    final parents1 = _getParents(memberId1);
    for (final parentId in parents1) {
      final parentSiblings = _getSiblings(parentId);
      if (parentSiblings.contains(memberId2)) {
        return MahramStatus(
          isMahram: true,
          reason: 'Paternal or maternal aunt/uncle',
          relationshipPath: _findPath(memberId1, memberId2),
          category: 'Nasab - Hawashi (Collaterals)',
        );
      }

      // Great aunts/uncles
      for (final auntUncleId in parentSiblings) {
        final cousins = _getChildren(auntUncleId);
        final grandparents = _getParents(parentId);
        for (final grandparentId in grandparents) {
          final greatAuntUncles = _getSiblings(grandparentId);
          if (greatAuntUncles.contains(memberId2)) {
            return MahramStatus(
              isMahram: true,
              reason: 'Great aunt/uncle (sibling of grandparent)',
              relationshipPath: _findPath(memberId1, memberId2),
              category: 'Nasab - Hawashi (Collaterals)',
            );
          }
        }
      }
    }

    return MahramStatus(isMahram: false, reason: '', relationshipPath: []);
  }

  MahramStatus _checkMusaharahMahram(String memberId1, String memberId2) {
    final member1 = state.members[memberId1]!;
    final member2 = state.members[memberId2]!;

    // 1. Pasangan's parents (mother-in-law, father-in-law) - PERMANENT mahram
    final spouses1 = _getPasangans(memberId1);
    for (final spouseId in spouses1) {
      final spouseParents = _getParents(spouseId);
      if (spouseParents.contains(memberId2)) {
        return MahramStatus(
          isMahram: true,
          reason:
              'Parent-in-law (mother-in-law or father-in-law) - Permanent mahram',
          relationshipPath: _findPath(memberId1, memberId2),
          category: 'Musaharah (Affinity)',
        );
      }

      // Pasangan's grandparents
      for (final spouseParentId in spouseParents) {
        final spouseGrandparents = _getParents(spouseParentId);
        if (spouseGrandparents.contains(memberId2)) {
          return MahramStatus(
            isMahram: true,
            reason: 'Grandparent-in-law - Permanent mahram',
            relationshipPath: _findPath(memberId1, memberId2),
            category: 'Musaharah (Affinity)',
          );
        }
      }
    }

    // 2. Children's spouses (daughter-in-law, son-in-law) - PERMANENT mahram
    final children1 = _getChildren(memberId1);
    for (final childId in children1) {
      final childPasangans = _getPasangans(childId);
      if (childPasangans.contains(memberId2)) {
        return MahramStatus(
          isMahram: true,
          reason:
              'Child-in-law (daughter-in-law or son-in-law) - Permanent mahram',
          relationshipPath: _findPath(memberId1, memberId2),
          category: 'Musaharah (Affinity)',
        );
      }
    }

    // Grandchildren's spouses
    for (final childId in children1) {
      final grandchildren = _getChildren(childId);
      for (final grandchildId in grandchildren) {
        final grandchildPasangans = _getPasangans(grandchildId);
        if (grandchildPasangans.contains(memberId2)) {
          return MahramStatus(
            isMahram: true,
            reason: 'Grandchild-in-law - Permanent mahram',
            relationshipPath: _findPath(memberId1, memberId2),
            category: 'Musaharah (Affinity)',
          );
        }
      }
    }

    // 3. Step-parent's relationship (spouse's parent to you) - PERMANENT if marriage consummated
    // 4. Step-children (spouse's children) - PERMANENT ONLY if marriage consummated
    for (final spouseId in spouses1) {
      final spouseChildren = _getChildren(spouseId);
      for (final stepchildId in spouseChildren) {
        if (stepchildId == memberId2) {
          final myChildren = _getChildren(memberId1);
          if (!myChildren.contains(stepchildId)) {
            return MahramStatus(
              isMahram: true,
              reason:
                  'Step-child (if marriage consummated) - Check marriage details',
              relationshipPath: _findPath(memberId1, memberId2),
              category: 'Musaharah (Affinity)',
            );
          }
        }
      }
    }

    // 5. Parent's spouse (step-parent)
    final parents1 = _getParents(memberId1);
    for (final parentId in parents1) {
      final parentPasangans = _getPasangans(parentId);
      if (parentPasangans.contains(memberId2)) {
        final otherParent = parents1.firstWhere(
          (p) => p != parentId,
          orElse: () => '',
        );
        if (otherParent != memberId2) {
          return MahramStatus(
            isMahram: true,
            reason: 'Step-parent (parent\'s spouse) - Permanent mahram',
            relationshipPath: _findPath(memberId1, memberId2),
            category: 'Musaharah (Affinity)',
          );
        }
      }
    }

    // 6. Ayah's wife / Ibu's husband (other than biological parent)
    for (final parentId in parents1) {
      final parentPasangans = _getPasangans(parentId);
      for (final stepParentId in parentPasangans) {
        if (stepParentId == memberId2 && !parents1.contains(memberId2)) {
          return MahramStatus(
            isMahram: true,
            reason: 'Step-parent - Permanent mahram',
            relationshipPath: _findPath(memberId1, memberId2),
            category: 'Musaharah (Affinity)',
          );
        }
      }
    }

    return MahramStatus(isMahram: false, reason: '', relationshipPath: []);
  }

  List<String> _getParents(String memberId) {
    return state.relations
        .where((r) => r.toId == memberId && r.type == RelationType.child)
        .map((r) => r.fromId)
        .toList();
  }

  List<String> _getChildren(String memberId) {
    return state.relations
        .where((r) => r.fromId == memberId && r.type == RelationType.child)
        .map((r) => r.toId)
        .toList();
  }

  List<String> _getPasangans(String memberId) {
    return state.relations
        .where(
          (r) =>
              (r.fromId == memberId || r.toId == memberId) &&
              r.type == RelationType.spouse,
        )
        .map((r) => r.fromId == memberId ? r.toId : r.fromId)
        .toList();
  }

  List<String> _getSiblings(String memberId) {
    final parents = _getParents(memberId);
    final siblings = <String>{};

    for (final parentId in parents) {
      final children = _getChildren(parentId);
      siblings.addAll(children.where((id) => id != memberId));
    }

    return siblings.toList();
  }

  List<String> _getAncestors(String memberId) {
    final ancestors = <String>{};
    final queue = [memberId];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final parents = _getParents(current);

      for (final parent in parents) {
        if (!ancestors.contains(parent)) {
          ancestors.add(parent);
          queue.add(parent);
        }
      }
    }

    return ancestors.toList();
  }

  List<String> _getDescendants(String memberId) {
    final descendants = <String>{};
    final queue = [memberId];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final children = _getChildren(current);

      for (final child in children) {
        if (!descendants.contains(child)) {
          descendants.add(child);
          queue.add(child);
        }
      }
    }

    return descendants.toList();
  }

  List<String> _findPath(String fromId, String toId) {
    final visited = <String>{};
    final queue = <List<String>>[];
    queue.add([fromId]);

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      final current = path.last;

      if (current == toId) {
        return path.map((id) => state.members[id]?.name ?? id).toList();
      }

      if (visited.contains(current)) continue;
      visited.add(current);

      final related = [
        ..._getParents(current),
        ..._getChildren(current),
        ..._getSiblings(current),
        ..._getPasangans(current),
      ];

      for (final relatedId in related) {
        if (!visited.contains(relatedId)) {
          queue.add([...path, relatedId]);
        }
      }
    }

    return [state.members[fromId]?.name ?? fromId];
  }

  // Complete inheritance calculation
  Future<void> calculateInheritance(
    String deceasedId, {
    double? estateValue,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final calculator = IslamicInheritanceCalculator(
        members: state.members,
        relations: state.relations,
        deceasedId: deceasedId,
        estateValue: estateValue ?? 0,
      );

      final result = calculator.calculate();
      setInheritanceData(result, deceasedId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to calculate inheritance: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Map<String, dynamic> exportToJson() {
    return {
      'tree':
          state.trees.firstWhere((t) => t.id == state.currentTreeId).toJson(),
      'members': state.members.values.map((m) => m.toJson()).toList(),
      'relations': state.relations.map((r) => r.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}
