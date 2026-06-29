import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class DashboardHeader extends StatelessWidget {
  final String selectedPeriod;
  final DateTime lastUpdated;
  final ValueChanged<String?> onPeriodChanged;
  final VoidCallback onRefresh;

  const DashboardHeader({
    super.key,
    required this.selectedPeriod,
    required this.lastUpdated,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HR Analytics Overview',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated ${DateFormat('MMM d, yyyy, HH:mm').format(lastUpdated)}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
              ),
            ],
          );

          final refreshButton = IconButton.filledTonal(
            tooltip: 'Refresh dashboard',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          );

          final periodPicker = SizedBox(
            width: isNarrow ? double.infinity : 220,
            child: DropdownButtonFormField<String>(
              initialValue: selectedPeriod,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Period',
                prefixIcon: Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items:
                  const [
                        'This Month',
                        'Last Month',
                        'Last Quarter',
                        'Last Year',
                      ]
                      .map(
                        (period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ),
                      )
                      .toList(),
              onChanged: onPeriodChanged,
            ),
          );

          final controls =
              isNarrow
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      periodPicker,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: refreshButton,
                      ),
                    ],
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      periodPicker,
                      const SizedBox(width: 10),
                      refreshButton,
                    ],
                  );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 16), controls],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 18),
              controls,
            ],
          );
        },
      ),
    );
  }
}
