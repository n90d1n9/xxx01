import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/timeline_provider.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({Key? key}) : super(key: key);
  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  DateTime? startDate;
  DateTime? endDate;
  int? minImpact;
  @override
  void initState() {
    super.initState();
    final state = ref.read(timelineProvider);
    startDate = state.startDate;
    endDate = state.endDate;
    minImpact = state.minImpactScore;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    startDate == null
                        ? 'Start Date'
                        : DateFormat('MMM d, y').format(startDate!),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(-3000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => startDate = date);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    endDate == null
                        ? 'End Date'
                        : DateFormat('MMM d, y').format(endDate!),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(-3000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => endDate = date);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Minimum Impact Score: ${minImpact ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: (minImpact ?? 0).toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: const Color(0xFF6C63FF),
            onChanged: (value) => setState(() => minImpact = value.toInt()),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      minImpact = null;
                    });
                    ref.read(timelineProvider.notifier).clearDateRange();
                    ref.read(timelineProvider.notifier).clearMinImpactScore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(timelineProvider.notifier)
                        .setDateRange(startDate, endDate);
                    ref
                        .read(timelineProvider.notifier)
                        .setMinImpactScore(minImpact);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
