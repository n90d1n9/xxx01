import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/management_pack_field_view_state.dart';
import '../models/management_pack_field_visibility_mode.dart';
import '../models/product_form_section.dart';
import 'management_pack_capability_field_group.dart';
import 'management_pack_field_empty_state.dart';
import 'management_pack_field_input.dart';
import 'management_pack_group_command_strip.dart';

/// Dynamic product editor fields contributed by the active management pack.
class ProductManagementPackFieldSection extends StatefulWidget {
  const ProductManagementPackFieldSection({
    super.key,
    required this.pack,
    required this.textControllers,
    required this.toggleValues,
    required this.onToggleChanged,
    this.focusedFieldId,
    this.focusedFieldRequestVersion = 0,
    this.groupProgress,
    this.onSelectField,
    this.fieldFocusNodes = const {},
    this.fieldKeys = const {},
  });

  final ProductManagementPack pack;
  final Map<ProductManagementFieldId, TextEditingController> textControllers;
  final Map<ProductManagementFieldId, bool> toggleValues;
  final void Function(ProductManagementPackField field, bool value)
  onToggleChanged;
  final ProductManagementFieldId? focusedFieldId;
  final int focusedFieldRequestVersion;
  final ProductManagementPackFieldGroupProgressOverview? groupProgress;
  final ValueChanged<ProductManagementPackField>? onSelectField;
  final Map<String, FocusNode> fieldFocusNodes;
  final Map<String, GlobalKey> fieldKeys;

  @override
  State<ProductManagementPackFieldSection> createState() =>
      _ProductManagementPackFieldSectionState();
}

class _ProductManagementPackFieldSectionState
    extends State<ProductManagementPackFieldSection> {
  var _expandedCapabilities = <ProductManagementCapability, bool>{};
  var _visibilityMode = ProductManagementPackFieldVisibilityMode.all;
  int? _appliedFocusedFieldRequestVersion;

  @override
  Widget build(BuildContext context) {
    final pendingFocusedFieldId = _pendingFocusedFieldId;
    _visibilityMode = _visibilityModeForFocusedField(pendingFocusedFieldId);
    final viewState = ProductManagementPackFieldViewState.fromPack(
      pack: widget.pack,
      visibilityMode: _visibilityMode,
      expandedCapabilities: _expandedCapabilities,
      groupProgress: widget.groupProgress,
      focusedFieldId: pendingFocusedFieldId,
    );
    if (!viewState.hasEditableFields) return const SizedBox.shrink();

    _expandedCapabilities = viewState.expandedCapabilities;
    _markFocusedFieldRequestApplied();

    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: '${widget.pack.title} data',
      subtitle: widget.pack.operatorFocusLabel,
      leadingIcon: Icons.dynamic_form_rounded,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: '${viewState.totalFieldCount} fields',
            color: colorScheme.primary,
            icon: Icons.view_list_rounded,
            maxWidth: 116,
          ),
          AppStatusPill(
            label: '${viewState.totalGroupCount} groups',
            color: colorScheme.tertiary,
            icon: Icons.account_tree_rounded,
            maxWidth: 128,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!viewState.hasVisibleGroups)
            ProductManagementPackFieldEmptyState(
              visibilityMode: _visibilityMode,
              onShowAllFields:
                  _visibilityMode ==
                          ProductManagementPackFieldVisibilityMode.all
                      ? null
                      : () => _setVisibilityMode(
                        ProductManagementPackFieldVisibilityMode.all,
                      ),
            )
          else ...[
            ProductManagementPackGroupCommandStrip(
              expandedGroupCount: viewState.expandedGroupCount,
              totalGroupCount: viewState.visibleGroupCount,
              lockedOpenGroupCount: viewState.lockedOpenGroupCount,
              visibleFieldCount: viewState.visibleFieldCount,
              totalFieldCount: viewState.totalFieldCount,
              visibilityMode: _visibilityMode,
              onVisibilityModeChanged: _setVisibilityMode,
              onExpandAll:
                  viewState.canExpandAll
                      ? () => _setExpandedCapabilities(viewState.expandAll())
                      : null,
              onCollapseReady:
                  viewState.canCollapseReady
                      ? () =>
                          _setExpandedCapabilities(viewState.collapseReady())
                      : null,
            ),
            const SizedBox(height: 14),
            for (final group in viewState.visibleGroups) ...[
              ProductManagementPackCapabilityFieldGroup(
                group: group,
                progress: viewState.progressFor(group.capability),
                isExpanded: viewState.isExpanded(group),
                onExpansionChanged:
                    viewState.canCollapse(group)
                        ? (isExpanded) => _setExpandedCapabilities(
                          viewState.withGroupExpanded(group, isExpanded),
                        )
                        : null,
                onSelectField: widget.onSelectField,
                fieldBuilder:
                    (field) =>
                        _anchoredPackField(field, _packFieldInput(field)),
              ),
              if (group != viewState.visibleGroups.last)
                const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }

  void _setVisibilityMode(ProductManagementPackFieldVisibilityMode mode) {
    if (_visibilityMode == mode) return;

    setState(() {
      _visibilityMode = mode;
    });
  }

  void _setExpandedCapabilities(
    Map<ProductManagementCapability, bool> expandedCapabilities,
  ) {
    setState(() {
      _expandedCapabilities = expandedCapabilities;
    });
  }

  ProductManagementFieldId? get _pendingFocusedFieldId {
    final focusedFieldId = widget.focusedFieldId;
    if (focusedFieldId == null) return null;
    if (_appliedFocusedFieldRequestVersion ==
        widget.focusedFieldRequestVersion) {
      return null;
    }

    return focusedFieldId;
  }

  ProductManagementPackFieldVisibilityMode _visibilityModeForFocusedField(
    ProductManagementFieldId? focusedFieldId,
  ) {
    if (focusedFieldId == null ||
        _visibilityMode == ProductManagementPackFieldVisibilityMode.all) {
      return _visibilityMode;
    }

    final focusedField = _editableFocusedField(focusedFieldId);
    if (focusedField == null || focusedField.required) return _visibilityMode;

    return ProductManagementPackFieldVisibilityMode.all;
  }

  ProductManagementPackField? _editableFocusedField(
    ProductManagementFieldId focusedFieldId,
  ) {
    for (final field in productManagementPackEditableFields(widget.pack)) {
      if (field.id == focusedFieldId) return field;
    }

    return null;
  }

  void _markFocusedFieldRequestApplied() {
    if (widget.focusedFieldId == null) return;

    _appliedFocusedFieldRequestVersion = widget.focusedFieldRequestVersion;
  }

  Widget _anchoredPackField(ProductManagementPackField field, Widget child) {
    final fieldKey = widget.fieldKeys[field.id.value];
    if (fieldKey == null) return child;

    return KeyedSubtree(key: fieldKey, child: child);
  }

  Widget _packFieldInput(ProductManagementPackField field) {
    return ProductManagementPackFieldInput(
      field: field,
      controller: widget.textControllers[field.id],
      value: widget.toggleValues[field.id] ?? false,
      autofocus: field.id == widget.focusedFieldId,
      focusNode: widget.fieldFocusNodes[field.id.value],
      onToggleChanged: (value) => widget.onToggleChanged(field, value),
    );
  }
}

@Preview(name: 'Management pack field section')
Widget productManagementPackFieldSectionPreview() {
  final pack = groceryFreshGoodsProductManagementPack;
  final textControllers = {
    for (final field in productManagementPackEditableFields(pack))
      if (field.type != ProductManagementFieldType.toggle)
        field.id: TextEditingController(text: _previewValueFor(field)),
  };
  final toggleValues = {
    for (final field in productManagementPackEditableFields(pack))
      if (field.type == ProductManagementFieldType.toggle) field.id: true,
  };
  final groups = buildProductManagementPackFieldGroups(pack);
  final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
    groups: groups,
    values: const {
      'barcode': '8990001',
      'expiry_date': '2026-07-01',
      'shelf_life_days': '5',
    },
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackFieldSection(
          pack: pack,
          textControllers: textControllers,
          toggleValues: toggleValues,
          groupProgress: groupProgress,
          onToggleChanged: (_, _) {},
        ),
      ),
    ),
  );
}

String _previewValueFor(ProductManagementPackField field) {
  if (field.options.isNotEmpty) return field.options.first;

  switch (field.type) {
    case ProductManagementFieldType.number:
      return '12';
    case ProductManagementFieldType.date:
      return '2026-06-09';
    case ProductManagementFieldType.text:
    case ProductManagementFieldType.select:
    case ProductManagementFieldType.toggle:
      return '';
  }
}
