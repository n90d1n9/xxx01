import 'pos_data_contract_model.dart';
import 'pos_data_trait.dart';

abstract final class POSInventoryDataContracts {
  static const inventory = POSDataTraitContract(
    traitKey: POSDataTraitKeys.inventory,
    requiredFields: [
      POSDataContractField('sku', 'SKU'),
      POSDataContractField('stock_on_hand', 'Stock on hand'),
    ],
  );

  static const variants = POSDataTraitContract(
    traitKey: POSDataTraitKeys.variants,
    requiredFields: [
      POSDataContractField('parent_product_id', 'Parent product id'),
      POSDataContractField('variant_id', 'Variant id'),
      POSDataContractField('option_values', 'Option values'),
    ],
  );

  static const weightedItems = POSDataTraitContract(
    traitKey: POSDataTraitKeys.weightedItems,
    requiredFields: [
      POSDataContractField('unit_of_measure', 'Unit of measure'),
      POSDataContractField('unit_price', 'Unit price'),
      POSDataContractField('captured_weight', 'Captured weight'),
    ],
  );

  static const serialTracked = POSDataTraitContract(
    traitKey: POSDataTraitKeys.serialTracked,
    requiredFields: [
      POSDataContractField('product_id', 'Product id'),
      POSDataContractField('serial_number', 'Serial number'),
    ],
  );

  static const batchTracked = POSDataTraitContract(
    traitKey: POSDataTraitKeys.batchTracked,
    requiredFields: [
      POSDataContractField('product_id', 'Product id'),
      POSDataContractField('batch_number', 'Batch number'),
      POSDataContractField('expiry_date', 'Expiry date'),
    ],
  );

  static const bundles = POSDataTraitContract(
    traitKey: POSDataTraitKeys.bundles,
    requiredFields: [
      POSDataContractField('bundle_id', 'Bundle id'),
      POSDataContractField('component_items', 'Component items'),
    ],
  );

  static const all = [
    inventory,
    variants,
    weightedItems,
    serialTracked,
    batchTracked,
    bundles,
  ];
}
