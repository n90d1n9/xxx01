import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/product_core_information_form_controller.dart';
import '../controllers/product_management_pack_form_controller.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_editor_form_layout.dart';
import '../models/product_editor_header_view_state.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_editor_context_header.dart';
import 'product_editor_field_stack.dart';
import 'product_editor_guidance_stack.dart';
import 'product_editor_side_rail.dart';
import 'product_editor_workspace_layout.dart';
import 'product_form_save_action_panel.dart';

/// Full product editor form content composed from reusable editor sections.
class ProductEditorFormContent extends StatelessWidget {
  const ProductEditorFormContent({
    super.key,
    required this.pack,
    required this.sectionOverview,
    required this.sectionProgress,
    required this.groupProgress,
    required this.saveSummary,
    required this.coreFields,
    required this.packFields,
    required this.isEditing,
    required this.onSubmit,
    required this.onPackToggleChanged,
    this.scrollKey = const ValueKey('product-form-scroll-view'),
    this.padding = const EdgeInsets.all(16),
    this.focusedPackFieldId,
    this.focusedPackFieldRequestVersion = 0,
    this.onSelectCoreField,
    this.onSelectAttribute,
    this.onSelectMissingAttribute,
    this.onSelectPackField,
    this.fieldFocusNodes = const {},
    this.fieldKeys = const {},
  });

  final ProductManagementPack pack;
  final ProductFormSectionOverview sectionOverview;
  final ProductFormSectionProgressOverview sectionProgress;
  final ProductManagementPackFieldGroupProgressOverview groupProgress;
  final ProductFormSaveActionSummary saveSummary;
  final ProductCoreInformationFormController coreFields;
  final ProductManagementPackFormController packFields;
  final bool isEditing;
  final VoidCallback onSubmit;
  final void Function(ProductManagementPackField field, bool value)
  onPackToggleChanged;
  final Key? scrollKey;
  final EdgeInsetsGeometry padding;
  final ProductManagementFieldId? focusedPackFieldId;
  final int focusedPackFieldRequestVersion;
  final ValueChanged<String>? onSelectCoreField;
  final ValueChanged<ProductFormAttributeDefinition>? onSelectAttribute;
  final ValueChanged<ProductFormMissingRequiredAttribute>?
  onSelectMissingAttribute;
  final ValueChanged<ProductManagementPackField>? onSelectPackField;
  final Map<String, FocusNode> fieldFocusNodes;
  final Map<String, GlobalKey> fieldKeys;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: scrollKey,
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ProductEditorFormLayout.forWidth(constraints.maxWidth);

          return ProductEditorWorkspaceLayout(
            layout: layout,
            header: _buildContextHeader(),
            primaryContent: _buildEditorFields(),
            sideRail: _buildSideRail(),
            compactGuidance: _buildGuidanceStack(),
            compactSaveAction: _buildSaveActionPanel(),
          );
        },
      ),
    );
  }

  Widget _buildContextHeader() {
    return ProductEditorContextHeader(
      viewState: ProductEditorHeaderViewState.from(
        pack: pack,
        saveSummary: saveSummary,
        isEditing: isEditing,
      ),
    );
  }

  Widget _buildEditorFields() {
    return ProductEditorFieldStack(
      pack: pack,
      coreFields: coreFields,
      packFields: packFields,
      groupProgress: groupProgress,
      isEditing: isEditing,
      focusedPackFieldId: focusedPackFieldId,
      focusedPackFieldRequestVersion: focusedPackFieldRequestVersion,
      onSelectCoreField: onSelectCoreField,
      onSelectPackField: onSelectPackField,
      onPackToggleChanged: onPackToggleChanged,
      fieldFocusNodes: fieldFocusNodes,
      fieldKeys: fieldKeys,
    );
  }

  Widget _buildSideRail() {
    return ProductEditorSideRail(
      overview: sectionOverview,
      progress: sectionProgress,
      groupProgress: groupProgress,
      saveSummary: saveSummary,
      onSelectAttribute: onSelectAttribute,
      onSelectMissingAttribute: onSelectMissingAttribute,
      onSubmit: onSubmit,
    );
  }

  Widget _buildGuidanceStack() {
    return ProductEditorGuidanceStack(
      overview: sectionOverview,
      progress: sectionProgress,
      groupProgress: groupProgress,
      onSelectAttribute: onSelectAttribute,
      onSelectMissingAttribute: onSelectMissingAttribute,
    );
  }

  Widget _buildSaveActionPanel() {
    return ProductFormSaveActionPanel(
      summary: saveSummary,
      onReviewIssueSelected:
          onSelectMissingAttribute == null
              ? null
              : (issue) => onSelectMissingAttribute!(issue.attribute),
      onReviewNext:
          saveSummary.nextReviewAttribute == null ||
                  onSelectMissingAttribute == null
              ? null
              : () =>
                  onSelectMissingAttribute!(saveSummary.nextReviewAttribute!),
      onSubmit: onSubmit,
    );
  }
}

@Preview(name: 'Product editor form content')
Widget productEditorFormContentPreview() {
  final fixture = _ProductEditorFormContentPreviewFixture();

  return MaterialApp(
    home: Scaffold(
      body: Form(
        child: ProductEditorFormContent(
          pack: fixture.pack,
          sectionOverview: fixture.sectionOverview,
          sectionProgress: fixture.sectionProgress,
          groupProgress: fixture.groupProgress,
          saveSummary: fixture.saveSummary,
          coreFields: fixture.coreFields,
          packFields: fixture.packFields,
          isEditing: false,
          onSelectAttribute: (_) {},
          onSelectMissingAttribute: (_) {},
          onSelectPackField: (_) {},
          onPackToggleChanged: fixture.packFields.setToggleValue,
          onSubmit: () {},
        ),
      ),
    ),
  );
}

/// Preview fixture for the product editor form content composition.
class _ProductEditorFormContentPreviewFixture {
  _ProductEditorFormContentPreviewFixture()
    : pack = groceryFreshGoodsProductManagementPack,
      coreFields = ProductCoreInformationFormController.fromProduct(null),
      packFields = ProductManagementPackFormController() {
    coreFields.nameController.text = 'Spinach';
    coreFields.skuController.text = 'SP-001';
    coreFields.categoryController.text = 'Fresh produce';
    coreFields.descriptionController.text = 'Leafy greens';
    packFields.ensurePackFields(pack);
    packFields.textControllers[ProductManagementFieldId.expiryDate]?.text =
        '2026-07-01';
  }

  final ProductManagementPack pack;
  final ProductCoreInformationFormController coreFields;
  final ProductManagementPackFormController packFields;

  ProductFormSectionOverview get sectionOverview {
    return buildProductFormSectionOverview(pack: pack, isEditing: false);
  }

  Map<String, String> get progressValues {
    return {...coreFields.progressValues(), ...packFields.progressValues(pack)};
  }

  ProductFormSectionProgressOverview get sectionProgress {
    return buildProductFormSectionProgressOverview(
      overview: sectionOverview,
      values: progressValues,
    );
  }

  ProductManagementPackFieldGroupProgressOverview get groupProgress {
    return buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(pack),
      values: progressValues,
    );
  }

  ProductFormSaveActionSummary get saveSummary {
    return buildProductFormSaveActionSummary(
      progress: sectionProgress,
      submitLabel: 'Add product',
      isEditing: false,
      groupProgress: groupProgress,
    );
  }
}
