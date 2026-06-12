import 'package:flutter/material.dart';

import '../models/management_pack.dart';
import '../models/product_core_information_field_ids.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';

/// Coordinates product editor field anchors, focus nodes, and scroll targeting.
class ProductEditorFieldFocusController {
  final _fieldFocusNodes = <String, FocusNode>{};
  final _fieldKeys = <String, GlobalKey>{};

  Map<String, FocusNode> get fieldFocusNodes {
    return Map.unmodifiable(_fieldFocusNodes);
  }

  Map<String, GlobalKey> get fieldKeys {
    return Map.unmodifiable(_fieldKeys);
  }

  /// Ensures anchors exist for all core product information fields.
  void ensureCoreInformationFieldAnchors() {
    for (final fieldId in ProductCoreInformationFieldIds.all) {
      ensureFieldAnchor(fieldId);
    }
  }

  /// Ensures anchors exist for all editable fields contributed by the pack.
  void ensurePackFieldAnchors(ProductManagementPack pack) {
    for (final field in productManagementPackEditableFields(pack)) {
      ensureFieldAnchor(field.id.value);
    }
  }

  /// Ensures a focus node and widget key exist for the field id.
  void ensureFieldAnchor(String fieldId) {
    fieldKeyFor(fieldId);
    focusNodeFor(fieldId);
  }

  GlobalKey fieldKeyFor(String fieldId) {
    return _fieldKeys.putIfAbsent(
      fieldId,
      () => GlobalKey(debugLabel: 'product-field-$fieldId'),
    );
  }

  FocusNode focusNodeFor(String fieldId) {
    return _fieldFocusNodes.putIfAbsent(
      fieldId,
      () => FocusNode(debugLabel: 'product-field-$fieldId'),
    );
  }

  Future<void> focusMissingAttribute(
    ProductFormMissingRequiredAttribute attribute, {
    required bool Function() isMounted,
  }) async {
    await focusFieldById(attribute.fieldId, isMounted: isMounted);
  }

  Future<void> focusAttributeDefinition(
    ProductFormAttributeDefinition attribute, {
    required bool Function() isMounted,
  }) async {
    await focusFieldById(attribute.id, isMounted: isMounted);
  }

  Future<void> focusManagementPackField(
    ProductManagementPackField field, {
    required bool Function() isMounted,
  }) async {
    await focusFieldById(field.id.value, isMounted: isMounted);
  }

  /// Scrolls to the field when mounted, then requests focus for keyboard entry.
  Future<void> focusFieldById(
    String fieldId, {
    required bool Function() isMounted,
  }) async {
    final fieldKey = fieldKeyFor(fieldId);
    final fieldContext = fieldKey.currentContext;
    if (fieldContext != null) {
      await Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    }
    if (!isMounted()) return;

    focusNodeFor(fieldId).requestFocus();
  }

  void dispose() {
    for (final focusNode in _fieldFocusNodes.values) {
      focusNode.dispose();
    }
    _fieldFocusNodes.clear();
    _fieldKeys.clear();
  }
}
