import 'package:flutter/material.dart';

import 'branch_form_controller_bundle.dart';
import 'branch_preview_data.dart';

Widget inventoryBranchFormPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

InventoryBranchFormControllerBundle inventoryBranchFormPreviewControllers() {
  return InventoryBranchFormControllerBundle.fromBranch(
    inventoryBranchPreviewBranch(),
  );
}
