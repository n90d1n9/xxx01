import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_surface.dart';
import 'admin_section_header.dart';

class AdminDataListSection extends StatelessWidget {
  const AdminDataListSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.emptyState,
    this.elevated = true,
  });

  final String title;
  final List<Widget> children;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final AppEmptyState? emptyState;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      elevated: elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionHeader(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            trailing: trailing,
          ),
          const SizedBox(height: 14),
          if (children.isEmpty)
            emptyState ??
                const AppEmptyState(
                  title: 'No records yet',
                  message: 'Records will appear when data is available.',
                )
          else
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index < children.length - 1) const Divider(height: 20),
            ],
        ],
      ),
    );
  }
}
