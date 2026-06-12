import 'pos_data_trait.dart';

class POSDataContractField {
  final String key;
  final String label;
  final String description;

  const POSDataContractField(this.key, this.label, [this.description = '']);
}

class POSDataTraitContract {
  final String traitKey;
  final List<POSDataContractField> requiredFields;
  final List<POSDataContractField> recommendedFields;

  const POSDataTraitContract({
    required this.traitKey,
    required this.requiredFields,
    this.recommendedFields = const [],
  });

  String get traitLabel => POSDataTraits.labelFor(traitKey);

  List<String> get requiredFieldLabels {
    return requiredFields.map((field) => field.label).toList(growable: false);
  }
}

class POSDataTraitAdapter {
  final String id;
  final String label;
  final Map<String, List<String>> fieldsByTrait;

  const POSDataTraitAdapter({
    required this.id,
    required this.label,
    required this.fieldsByTrait,
  });

  bool supportsTrait(String traitKey) {
    return fieldsByTrait.containsKey(traitKey.trim());
  }

  bool supportsField(String traitKey, String fieldKey) {
    final fields = fieldsByTrait[traitKey.trim()];
    if (fields == null) return false;

    return fields.contains(fieldKey.trim());
  }

  List<POSDataContractField> missingRequiredFields(
    POSDataTraitContract contract,
  ) {
    return contract.requiredFields
        .where((field) => !supportsField(contract.traitKey, field.key))
        .toList(growable: false);
  }

  bool satisfies(POSDataTraitContract contract) {
    return supportsTrait(contract.traitKey) &&
        missingRequiredFields(contract).isEmpty;
  }
}

class POSDataContractCoverage {
  final String traitKey;
  final POSDataTraitContract? contract;
  final POSDataTraitAdapter? adapter;
  final List<POSDataContractField> missingRequiredFields;
  final bool adapterRequired;

  const POSDataContractCoverage({
    required this.traitKey,
    required this.contract,
    required this.adapter,
    required this.missingRequiredFields,
    required this.adapterRequired,
  });

  String get traitLabel =>
      contract?.traitLabel ?? POSDataTraits.labelFor(traitKey);

  bool get hasContract => contract != null;

  bool get hasAdapter => adapter != null;

  bool get satisfied {
    if (!hasContract) return false;
    if (!adapterRequired) return true;
    return hasAdapter && missingRequiredFields.isEmpty;
  }

  String get detail {
    if (!hasContract) return 'No contract definition is registered.';
    if (!adapterRequired) {
      return '${contract!.requiredFields.length} required field${contract!.requiredFields.length == 1 ? '' : 's'} documented.';
    }
    if (!hasAdapter) return 'No adapter declares this trait.';
    if (missingRequiredFields.isEmpty) {
      return '${adapter!.label} satisfies required fields.';
    }

    final labels = missingRequiredFields.map((field) => field.label).join(', ');
    return '${adapter!.label} is missing $labels.';
  }
}
