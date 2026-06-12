import 'package:flutter/material.dart';

import 'dashboard_large.dart';

class DashboardPhoneScreen extends StatelessWidget {
  const DashboardPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardOverview(padding: EdgeInsets.all(16), compact: true);
  }
}
