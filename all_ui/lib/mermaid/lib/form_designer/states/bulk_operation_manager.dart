import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/field_config.dart';
import 'form_field_provider.dart';
import 'selection_provider.dart';

class BulkOperationsManager {
  static void deleteSelected(WidgetRef ref, Set<String> ids) {
    for (final id in ids) {
      ref.read(formFieldsProvider.notifier).deleteField(id);
    }
    ref.read(selectionManagerProvider.notifier).clearSelection();
  }

  static void duplicateSelected(
    WidgetRef ref,
    List<FieldConfig> fields,
    Set<String> ids,
  ) {
    final fieldsToDuplicate = fields.where((f) => ids.contains(f.id)).toList();
    for (final field in fieldsToDuplicate) {
      ref.read(formFieldsProvider.notifier).duplicateField(field);
    }
  }

  static void bulkUpdateRequired(
    WidgetRef ref,
    List<FieldConfig> fields,
    Set<String> ids,
    bool required,
  ) {
    for (final id in ids) {
      final field = fields.firstWhere((f) => f.id == id);
      if (!field.isContainer) {
        ref
            .read(formFieldsProvider.notifier)
            .updateField(id, field.copyWith(required: required));
      }
    }
  }
}
