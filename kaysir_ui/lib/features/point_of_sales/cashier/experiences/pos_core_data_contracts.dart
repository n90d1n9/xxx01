import 'pos_data_contract_model.dart';
import 'pos_data_trait.dart';

abstract final class POSCoreDataContracts {
  static const catalog = POSDataTraitContract(
    traitKey: POSDataTraitKeys.catalog,
    requiredFields: [
      POSDataContractField('product_id', 'Product id'),
      POSDataContractField('product_name', 'Product name'),
      POSDataContractField('price', 'Price'),
    ],
  );

  static const menu = POSDataTraitContract(
    traitKey: POSDataTraitKeys.menu,
    requiredFields: [
      POSDataContractField('menu_item_id', 'Menu item id'),
      POSDataContractField('menu_name', 'Menu name'),
      POSDataContractField('base_price', 'Base price'),
    ],
    recommendedFields: [
      POSDataContractField('modifier_group_ids', 'Modifier group ids'),
    ],
  );

  static const orders = POSDataTraitContract(
    traitKey: POSDataTraitKeys.orders,
    requiredFields: [
      POSDataContractField('order_id', 'Order id'),
      POSDataContractField('line_items', 'Line items'),
      POSDataContractField('total', 'Total'),
      POSDataContractField('status', 'Status'),
    ],
  );

  static const customers = POSDataTraitContract(
    traitKey: POSDataTraitKeys.customers,
    requiredFields: [
      POSDataContractField('customer_id', 'Customer id'),
      POSDataContractField('display_name', 'Display name'),
    ],
    recommendedFields: [POSDataContractField('contact', 'Contact')],
  );

  static const payments = POSDataTraitContract(
    traitKey: POSDataTraitKeys.payments,
    requiredFields: [
      POSDataContractField('payment_method', 'Payment method'),
      POSDataContractField('tendered_amount', 'Tendered amount'),
      POSDataContractField('payment_status', 'Payment status'),
    ],
  );

  static const promotions = POSDataTraitContract(
    traitKey: POSDataTraitKeys.promotions,
    requiredFields: [
      POSDataContractField('promotion_code', 'Promotion code'),
      POSDataContractField('discount_value', 'Discount value'),
    ],
  );

  static const all = [catalog, menu, orders, customers, payments, promotions];
}
