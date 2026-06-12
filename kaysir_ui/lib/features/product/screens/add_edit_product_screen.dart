import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../controllers/product_core_information_form_controller.dart';
import '../controllers/product_editor_field_focus_controller.dart';
import '../controllers/product_management_pack_form_controller.dart';
import '../models/product.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import '../states/management_pack_provider.dart';
import '../states/product_provider.dart';
import '../states/stock_movement_provider.dart';
import '../utils/product_form_draft.dart';
import '../widgets/product_editor_form_content.dart';

typedef ProductFormSaved =
    void Function(Product product, Product? previousProduct);

class AddEditProductScreen extends ConsumerStatefulWidget {
  const AddEditProductScreen({
    super.key,
    this.product,
    this.initialFocusFieldId,
    this.onProductSaved,
  });

  final Product? product;
  final ProductManagementFieldId? initialFocusFieldId;
  final ProductFormSaved? onProductSaved;

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProductCoreInformationFormController _coreFields;
  late ProductManagementPackFormController _packFields;
  late final VoidCallback _formProgressListener;
  final _fieldFocus = ProductEditorFieldFocusController();
  ProductManagementFieldId? _focusedPackFieldId;
  var _focusedPackFieldRequestVersion = 0;

  @override
  void initState() {
    super.initState();
    _formProgressListener = () {
      if (mounted) setState(() {});
    };
    _coreFields = ProductCoreInformationFormController.fromProduct(
      widget.product,
    )..attachListener(_formProgressListener);
    _packFields = ProductManagementPackFormController(product: widget.product)
      ..attachListener(_formProgressListener);
    _focusedPackFieldId = widget.initialFocusFieldId;
    if (_focusedPackFieldId != null) {
      _focusedPackFieldRequestVersion = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AddEditProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFocusFieldId == oldWidget.initialFocusFieldId) return;

    _focusedPackFieldId = widget.initialFocusFieldId;
    if (_focusedPackFieldId != null) {
      _focusedPackFieldRequestVersion += 1;
    }
  }

  @override
  void dispose() {
    _coreFields.dispose();
    _packFields.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final submitLabel = isEditing ? 'Update product' : 'Add product';
    final managementPack = ref.watch(productManagementPackProvider);
    final sectionOverview = buildProductFormSectionOverview(
      pack: managementPack,
      isEditing: isEditing,
    );
    _ensureCoreInformationFieldAnchors();
    _ensurePackFieldState(managementPack);
    final formProgressValues = _formProgressValues(managementPack);
    final sectionProgress = buildProductFormSectionProgressOverview(
      overview: sectionOverview,
      values: formProgressValues,
    );
    final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(managementPack),
      values: formProgressValues,
    );
    final saveSummary = buildProductFormSaveActionSummary(
      progress: sectionProgress,
      submitLabel: submitLabel,
      isEditing: isEditing,
      groupProgress: groupProgress,
    );

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: ProductEditorFormContent(
          pack: managementPack,
          sectionOverview: sectionOverview,
          sectionProgress: sectionProgress,
          groupProgress: groupProgress,
          saveSummary: saveSummary,
          coreFields: _coreFields,
          packFields: _packFields,
          isEditing: isEditing,
          focusedPackFieldId: _focusedPackFieldId,
          focusedPackFieldRequestVersion: _focusedPackFieldRequestVersion,
          onSelectCoreField: _focusCoreInformationField,
          onSelectAttribute: _focusProductFormAttributeDefinition,
          onSelectMissingAttribute: _focusProductFormAttribute,
          onSelectPackField: _focusManagementPackField,
          fieldFocusNodes: _fieldFocus.fieldFocusNodes,
          fieldKeys: _fieldFocus.fieldKeys,
          onPackToggleChanged: (field, value) {
            setState(() {
              _packFields.setToggleValue(field, value);
            });
          },
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }

  ProductFormDraft _draftFromControllers() {
    final managementPack = ref.read(productManagementPackProvider);

    return _coreFields.toDraft(
      barcode: _packFields.barcodeText,
      unit: _packFields.unitText,
      customAttributes: _packFields.customAttributes(managementPack),
    );
  }

  void _ensurePackFieldState(ProductManagementPack pack) {
    _fieldFocus.ensurePackFieldAnchors(pack);
    _packFields.ensurePackFields(pack);
  }

  void _ensureCoreInformationFieldAnchors() {
    _fieldFocus.ensureCoreInformationFieldAnchors();
  }

  Future<void> _focusProductFormAttribute(
    ProductFormMissingRequiredAttribute attribute,
  ) async {
    final packField = _packFieldForAttributeId(attribute.fieldId);
    if (packField != null) {
      await _focusManagementPackField(packField);
      return;
    }

    _clearFocusedPackField();
    await _fieldFocus.focusMissingAttribute(
      attribute,
      isMounted: () => mounted,
    );
  }

  Future<void> _focusProductFormAttributeDefinition(
    ProductFormAttributeDefinition attribute,
  ) async {
    final packField = _packFieldForAttributeId(attribute.id);
    if (packField != null) {
      await _focusManagementPackField(packField);
      return;
    }

    _clearFocusedPackField();
    await _fieldFocus.focusAttributeDefinition(
      attribute,
      isMounted: () => mounted,
    );
  }

  Future<void> _focusManagementPackField(
    ProductManagementPackField field,
  ) async {
    _requestPackFieldFocus(field.id);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    await _fieldFocus.focusManagementPackField(field, isMounted: () => mounted);
  }

  Future<void> _focusCoreInformationField(String fieldId) async {
    _clearFocusedPackField();
    await _fieldFocus.focusFieldById(fieldId, isMounted: () => mounted);
  }

  ProductManagementPackField? _packFieldForAttributeId(String fieldId) {
    final managementPack = ref.read(productManagementPackProvider);
    for (final field in productManagementPackEditableFields(managementPack)) {
      if (field.id.value == fieldId) return field;
    }

    return null;
  }

  void _requestPackFieldFocus(ProductManagementFieldId fieldId) {
    setState(() {
      _focusedPackFieldId = fieldId;
      _focusedPackFieldRequestVersion += 1;
    });
  }

  void _clearFocusedPackField() {
    if (_focusedPackFieldId == null) return;

    setState(() {
      _focusedPackFieldId = null;
    });
  }

  Map<String, String> _formProgressValues(ProductManagementPack pack) {
    final values = _coreFields.progressValues();
    values.addAll(_packFields.progressValues(pack));

    return values;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final draft = _draftFromControllers();
    final uuid = const Uuid();
    final existingProduct = widget.product;

    if (existingProduct != null) {
      final updatedProduct = draft.applyTo(existingProduct);
      if (widget.onProductSaved == null) {
        final productsNotifier = ref.read(productsProvider.notifier);
        productsNotifier.updateProduct(updatedProduct);
      } else {
        widget.onProductSaved!(updatedProduct, existingProduct);
      }
      Navigator.pop(context);
      return;
    }

    final newProduct = draft.toProduct(id: uuid.v4());
    if (widget.onProductSaved == null) {
      final productsNotifier = ref.read(productsProvider.notifier);
      productsNotifier.addProduct(newProduct);

      final movement = draft.initialStockMovement(
        id: uuid.v4(),
        productId: newProduct.id,
        date: DateTime.now(),
      );
      if (movement != null) {
        ref.read(stockMovementsProvider.notifier).addMovement(movement);
      }
    } else {
      widget.onProductSaved!(newProduct, null);
    }

    Navigator.pop(context);
  }
}
