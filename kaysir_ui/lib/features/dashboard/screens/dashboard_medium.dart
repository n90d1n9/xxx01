import 'package:flutter/material.dart';

import 'dashboard_large.dart';

class DashboardMediumScreen extends StatelessWidget {
  const DashboardMediumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardOverview(padding: EdgeInsets.all(20), compact: true);
  }
}
