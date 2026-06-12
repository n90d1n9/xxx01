import 'package:flutter/material.dart';
import 'package:ky_admin/widgets/admin_state_views.dart';

class LoadingDashboard extends StatelessWidget {
  const LoadingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLoadingState(
      title: 'Loading dashboard',
      message: 'Preparing the latest sales and product signals.',
      icon: Icons.dashboard_customize_outlined,
    );
  }
}

class DashboardUpdatingIndicator extends StatelessWidget {
  const DashboardUpdatingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPageUpdatingIndicator();
  }
}

class ErrorDashboard extends StatelessWidget {
  const ErrorDashboard({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return AdminErrorState(
      title: 'Unable to load dashboard',
      message: '$error',
    );
  }
}
