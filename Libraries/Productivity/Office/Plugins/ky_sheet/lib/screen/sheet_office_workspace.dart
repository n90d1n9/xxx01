import 'package:flutter/material.dart';
import 'package:ky_office/ky_office.dart';

import '../office_product.dart';
import 'spreadsheet_screen.dart';

class SheetOfficeWorkspace extends StatelessWidget {
  const SheetOfficeWorkspace({
    super.key,
    this.onProductSelected,
    this.trailing,
  });

  final ValueChanged<KyOfficeProductDescriptor>? onProductSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return OfficeFamilyShell(
      activeProductId: kySheetOfficeProduct.id,
      onProductSelected: onProductSelected,
      trailing: trailing,
      child: const SpreadsheetScreen(),
    );
  }
}
