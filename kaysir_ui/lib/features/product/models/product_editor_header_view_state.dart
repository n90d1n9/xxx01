import 'management_pack.dart';
import 'product_form_save_action.dart';

/// Presentation state for the product editor workspace header.
class ProductEditorHeaderViewState {
  const ProductEditorHeaderViewState({
    required this.title,
    required this.subtitle,
    required this.modeLabel,
    required this.packLabel,
    required this.businessModelLabel,
    required this.readinessLabel,
    required this.requiredReadinessLabel,
    required this.capabilityCountLabel,
    required this.packRequiredFieldCountLabel,
    required this.isReady,
    required this.isEditing,
  });

  /// Builds header copy from the active pack and save readiness summary.
  factory ProductEditorHeaderViewState.from({
    required ProductManagementPack pack,
    required ProductFormSaveActionSummary saveSummary,
    required bool isEditing,
  }) {
    return ProductEditorHeaderViewState(
      title: isEditing ? 'Edit product' : 'Add product',
      subtitle: pack.operatorFocusLabel,
      modeLabel: isEditing ? 'Edit mode' : 'New product',
      packLabel: pack.title,
      businessModelLabel: pack.businessModelLabel,
      readinessLabel: saveSummary.readinessPercentLabel,
      requiredReadinessLabel: saveSummary.requiredReadinessCountLabel,
      capabilityCountLabel: _countLabel(
        pack.capabilities.length,
        'capability',
        'capabilities',
      ),
      packRequiredFieldCountLabel: _countLabel(
        pack.requiredFields.length,
        'pack required field',
      ),
      isReady: saveSummary.isReady,
      isEditing: isEditing,
    );
  }

  final String title;
  final String subtitle;
  final String modeLabel;
  final String packLabel;
  final String businessModelLabel;
  final String readinessLabel;
  final String requiredReadinessLabel;
  final String capabilityCountLabel;
  final String packRequiredFieldCountLabel;
  final bool isReady;
  final bool isEditing;
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
