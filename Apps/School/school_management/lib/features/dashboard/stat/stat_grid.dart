import 'package:flutter/material.dart';

import '../../admin/models/dashboard_content.dart';
import 'stat_card_widget.dart';

class StatGrid extends StatelessWidget {
  final DashboardContent content;
  const StatGrid({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).size.width < 600
                ? 1
                : MediaQuery.of(context).size.width < 900
                ? 2
                : 4,
        childAspectRatio: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: content.stats.length,
      itemBuilder: (context, index) {
        final stat = content.stats[index];
        return StatCardWidget(stat: stat);
      },
    );
  }
}
