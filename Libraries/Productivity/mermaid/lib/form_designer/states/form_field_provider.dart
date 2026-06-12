import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../history/add_field_command.dart';
import '../history/delete_field_command.dart';
import '../history/history_manager_provider.dart';
import '../history/reorder_field_command.dart';
import '../history/update_field_command.dart';
import '../model/field_config.dart';

final formFieldsProvider =
    StateNotifierProvider<FormFieldsNotifier, List<FieldConfig>>((ref) {
      return FormFieldsNotifier(ref);
    });

final selectedFieldProvider = StateProvider<FieldConfig?>((ref) => null);
final previewModeProvider = StateProvider<bool>((ref) => false);
final draggingIndexProvider = StateProvider<int?>((ref) => null);
final expandedContainersProvider = StateProvider<Set<String>>((ref) => {});

final selectedFieldsProvider = StateProvider<Set<String>>(
  (ref) => {},
); // Multi-select

final searchQueryProvider = StateProvider<String>((ref) => '');
final autoSaveProvider = StateProvider<bool>((ref) => true);
final lastSavedProvider = StateProvider<DateTime?>((ref) => null);

final showSearchProvider = StateProvider<bool>((ref) => false);

// =====

class FormFieldsNotifier extends StateNotifier<List<FieldConfig>> {
  final Ref ref;
  FormFieldsNotifier(this.ref) : super([]);

  // Public methods that create commands
  void addField(FieldConfig field, {String? parentId}) {
    final command = AddFieldCommand(this, field, parentId: parentId);
    ref.read(historyManagerProvider.notifier).executeCommand(command);
  }

  void loadFields(List<FieldConfig> fields) {
    state = fields;
    ref.read(historyManagerProvider.notifier).clear();
  }

  void insertFieldAt(FieldConfig field, int index) {
    final newState = List<FieldConfig>.from(state);
    newState.insert(index, field);
    state = newState;
  }

  /*  List<FieldConfig> _addFieldToContainer(
    List<FieldConfig> fields,
    String parentId,
    FieldConfig newField,
  ) {
    return fields.map((field) {
      if (field.id == parentId && field.children != null) {
        return field.copyWith(children: [...field.children!, newField]);
      } else if (field.children != null) {
        return field.copyWith(
          children: _addFieldToContainer(field.children!, parentId, newField),
        );
      }
      return field;
    }).toList();
  } */

  /*   void updateField(String id, FieldConfig updatedField) {
    state = _updateFieldRecursive(state, id, updatedField);
  } */

  void updateField(String id, FieldConfig updatedField) {
    final oldField = _findFieldById(state, id);
    if (oldField != null) {
      final command = UpdateFieldCommand(this, oldField, updatedField);
      ref.read(historyManagerProvider.notifier).executeCommand(command);
    }
  }

  /*  List<FieldConfig> _updateFieldRecursive(
    List<FieldConfig> fields,
    String id,
    FieldConfig updatedField,
  ) {
    return fields.map((field) {
      if (field.id == id) {
        return updatedField;
      } else if (field.children != null) {
        return field.copyWith(
          children: _updateFieldRecursive(field.children!, id, updatedField),
        );
      }
      return field;
    }).toList();
  } */

  /*   void deleteField(String id) {
    state = _deleteFieldRecursive(state, id);
  }
 */

  void deleteField(String id) {
    final field = _findFieldById(state, id);
    final index = _findFieldIndexById(state, id);
    if (field != null && index != -1) {
      final command = DeleteFieldCommand(this, field, index);
      ref.read(historyManagerProvider.notifier).executeCommand(command);
    }
  }

  void reorderField(int oldIndex, int newIndex) {
    final command = ReorderFieldCommand(this, oldIndex, newIndex);
    ref.read(historyManagerProvider.notifier).executeCommand(command);
  }

  /*   void reorderField(int oldIndex, int newIndex) {
    final newState = List<FieldConfig>.from(state);
    final field = newState.removeAt(oldIndex);
    newState.insert(newIndex, field);
    state = newState;
  } */

  /*   List<FieldConfig> _deleteFieldRecursive(List<FieldConfig> fields, String id) {
    return fields.where((field) => field.id != id).map((field) {
      if (field.children != null) {
        return field.copyWith(
          children: _deleteFieldRecursive(field.children!, id),
        );
      }
      return field;
    }).toList();
  } */

  void duplicateField(FieldConfig field) {
    final newField = _duplicateFieldRecursive(field);
    state = [...state, newField];
  }

  /*   FieldConfig _duplicateFieldRecursive(FieldConfig field) {
    return field.copyWith(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      name: field.name != null ? '${field.name}_copy' : null,
      children: field.children
          ?.map((child) => _duplicateFieldRecursive(child))
          .toList(),
    );
  }
 */

  /* String exportConfig() {
    final config = {
      'fields': state.map((f) => f.toJson()).toList(),
      'actions': [
        {
          'id': 'submit',
          'label': 'Submit',
          'type': 'primary',
          'requiresValidation': true,
        },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(config);
  }
 */
  //---------

  // Direct methods (used by commands, don't create new commands)
  void addFieldDirect(FieldConfig field, {String? parentId}) {
    if (parentId != null) {
      state = _addFieldToContainer(state, parentId, field);
    } else {
      state = [...state, field];
    }
  }

  void insertFieldDirect(FieldConfig field, int index) {
    final newState = List<FieldConfig>.from(state);
    newState.insert(index, field);
    state = newState;
  }

  void updateFieldDirect(String id, FieldConfig updatedField) {
    state = _updateFieldRecursive(state, id, updatedField);
  }

  void deleteFieldDirect(String id) {
    state = _deleteFieldRecursive(state, id);
  }

  void reorderFieldDirect(int oldIndex, int newIndex) {
    final newState = List<FieldConfig>.from(state);
    final field = newState.removeAt(oldIndex);
    newState.insert(newIndex, field);
    state = newState;
  }

  // Bulk operations for multi-select
  void deleteSelectedFields(Set<String> ids) {
    for (final id in ids) {
      deleteField(id);
    }
  }

  /*  void duplicateField(FieldConfig field) {
    final newField = _duplicateFieldRecursive(field);
    addField(newField);
  } */

  void clear() {
    state = [];
    ref.read(historyManagerProvider.notifier).clear();
  }

  // Helper methods
  FieldConfig? _findFieldById(List<FieldConfig> fields, String id) {
    for (final field in fields) {
      if (field.id == id) return field;
      if (field.children != null) {
        final found = _findFieldById(field.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  int _findFieldIndexById(List<FieldConfig> fields, String id) {
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].id == id) return i;
    }
    return -1;
  }

  List<FieldConfig> _addFieldToContainer(
    List<FieldConfig> fields,
    String parentId,
    FieldConfig newField,
  ) {
    return fields.map((field) {
      if (field.id == parentId && field.children != null) {
        return field.copyWith(children: [...field.children!, newField]);
      } else if (field.children != null) {
        return field.copyWith(
          children: _addFieldToContainer(field.children!, parentId, newField),
        );
      }
      return field;
    }).toList();
  }

  List<FieldConfig> _updateFieldRecursive(
    List<FieldConfig> fields,
    String id,
    FieldConfig updatedField,
  ) {
    return fields.map((field) {
      if (field.id == id) {
        return updatedField;
      } else if (field.children != null) {
        return field.copyWith(
          children: _updateFieldRecursive(field.children!, id, updatedField),
        );
      }
      return field;
    }).toList();
  }

  List<FieldConfig> _deleteFieldRecursive(List<FieldConfig> fields, String id) {
    return fields.where((field) => field.id != id).map((field) {
      if (field.children != null) {
        return field.copyWith(
          children: _deleteFieldRecursive(field.children!, id),
        );
      }
      return field;
    }).toList();
  }

  FieldConfig _duplicateFieldRecursive(FieldConfig field) {
    return field.copyWith(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      name: field.name != null ? '${field.name}_copy' : null,
      children: field.children
          ?.map((child) => _duplicateFieldRecursive(child))
          .toList(),
    );
  }

  String exportConfig() {
    final config = {
      'fields': state.map((f) => f.toJson()).toList(),
      'actions': [
        {
          'id': 'submit',
          'label': 'Submit',
          'type': 'primary',
          'requiresValidation': true,
        },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(config);
  }
}
