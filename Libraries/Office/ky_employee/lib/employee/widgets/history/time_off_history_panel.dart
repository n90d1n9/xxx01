import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/ess_history_models.dart';
import '../../models/time_off_request.dart';

class TimeOffHistoryPanel extends StatelessWidget {
  final List<TimeOffRequest> requests;
  final TimeOffHistoryFilter selectedFilter;
  final ValueChanged<TimeOffHistoryFilter> onFilterChanged;
  final ValueChanged<TimeOffRequest> onCancel;

  const TimeOffHistoryPanel({
    super.key,
    required this.requests,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.event_available_outlined,
      title: 'Request history',
      subtitle: 'Track approval status and request details',
      emptyMessage: 'No time-off requests match this filter',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              TimeOffHistoryFilter.values.map((filter) {
                return FilterChip(
                  label: Text(filter.label),
                  selected: selectedFilter == filter,
                  onSelected: (_) => onFilterChanged(filter),
                );
              }).toList(),
        ),
        ...requests.map(
          (request) =>
              _TimeOffRequestExpansion(request: request, onCancel: onCancel),
        ),
      ],
    );
  }
}

class _TimeOffRequestExpansion extends StatelessWidget {
  final TimeOffRequest request;
  final ValueChanged<TimeOffRequest> onCancel;

  const _TimeOffRequestExpansion({
    required this.request,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);

    return HrisListSurface(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          request.reason,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${DateFormat('MMM d').format(request.startDate)} - ${DateFormat('MMM d, yyyy').format(request.endDate)}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: HrisStatusPill(label: request.status, color: color),
        children: [
          _RequestLine(label: 'Request ID', value: request.id),
          _RequestLine(
            label: 'Start date',
            value: DateFormat('MMM d, yyyy').format(request.startDate),
          ),
          _RequestLine(
            label: 'End date',
            value: DateFormat('MMM d, yyyy').format(request.endDate),
          ),
          _RequestLine(
            label: 'Duration',
            value: '${request.durationDays} day(s)',
          ),
          _RequestLine(
            label: 'Status',
            value: request.status,
            valueColor: color,
          ),
          if (request.isPending) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => onCancel(request),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel request'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _RequestLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'Approved':
      return const Color(0xFF15803D);
    case 'Pending':
      return const Color(0xFFD97706);
    case 'Rejected':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}
