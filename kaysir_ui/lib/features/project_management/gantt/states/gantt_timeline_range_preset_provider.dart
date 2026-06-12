import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/gantt_timeline_range_preset_service.dart';
import 'gantt_chart_preferences_provider.dart';

final ganttTimelineRangePresetProvider = Provider<GanttTimelineRangePreset>((
  ref,
) {
  return ref.watch(ganttChartTimelineRangePresetProvider);
});
