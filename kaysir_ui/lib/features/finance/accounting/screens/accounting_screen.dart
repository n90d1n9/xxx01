import 'package:flutter/material.dart';

import '../helper/responsive_breakpoint.dart';
import 'adjusment_screen.dart';
import 'adjustment_entry_screen.dart';

class ResponsiveAccountingScreen extends StatelessWidget {
  const ResponsiveAccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return const DesktopAccountingLayout();
        } else {
          // Fall back to the original mobile layout
          return const AccountingAdjustmentScreen();
        }
      },
    );
  }
}
