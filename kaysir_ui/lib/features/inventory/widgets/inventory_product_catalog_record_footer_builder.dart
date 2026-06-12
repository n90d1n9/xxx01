import 'package:flutter/widgets.dart';

import '../models/inventory_product_catalog.dart';

typedef InventoryProductCatalogRecordFooterBuilder =
    Widget? Function(
      BuildContext context,
      InventoryProductCatalogRecord record,
    );
