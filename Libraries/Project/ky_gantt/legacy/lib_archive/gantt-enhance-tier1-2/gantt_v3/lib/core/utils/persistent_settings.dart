import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';
import '../providers/gantt_providers.dart';

/// Persists GanttViewSettings and GanttFilter to a local JSON file.
/// Called once on app start (load) and after every relevant state change (save).
/// Uses path_provider — no external key-value package needed.

const _kFileName = 'gantt_settings.json';

class PersistentSettings {
  // ─── Load ──────────────────────────────────────────────────────────────────
  static Future<({GanttViewSettings settings, GanttFilter filter})>
      load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _defaults();
      final raw = await file.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (
        settings:
            _settingsFromMap(map['settings'] as Map<String, dynamic>? ?? {}),
        filter: _filterFromMap(map['filter'] as Map<String, dynamic>? ?? {}),
      );
    } catch (_) {
      return _defaults();
    }
  }

  // ─── Save ──────────────────────────────────────────────────────────────────
  static Future<void> save(
      GanttViewSettings settings, GanttFilter filter) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode({
        'settings': _settingsToMap(settings),
        'filter': _filterToMap(filter),
      }));
    } catch (_) {}
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_kFileName');
  }

  static ({GanttViewSettings settings, GanttFilter filter}) _defaults() => (
        settings: const GanttViewSettings(),
        filter: const GanttFilter(),
      );

  static Map<String, dynamic> _settingsToMap(GanttViewSettings s) => {
        'dayWidth': s.dayWidth,
        'viewMode': s.viewMode.index,
        'showWeekends': s.showWeekends,
        'showCriticalPath': s.showCriticalPath,
        'showDependencies': s.showDependencies,
        'showBaseline': s.showBaseline,
        'showResourceHistogram': s.showResourceHistogram,
        'sidebarWidth': s.sidebarWidth,
        'autoScheduleEnabled': s.autoScheduleEnabled,
        'swimlaneGroupBy': s.swimlaneGroupBy.index,
      };

  static GanttViewSettings _settingsFromMap(Map<String, dynamic> m) {
    final modeIdx = (m['viewMode'] as int?) ?? 1;
    final swimIdx = (m['swimlaneGroupBy'] as int?) ?? 0;
    return GanttViewSettings(
      dayWidth: (m['dayWidth'] as num?)?.toDouble() ?? 32,
      viewMode: GanttViewMode
          .values[modeIdx.clamp(0, GanttViewMode.values.length - 1)],
      showWeekends: m['showWeekends'] as bool? ?? true,
      showCriticalPath: m['showCriticalPath'] as bool? ?? false,
      showDependencies: m['showDependencies'] as bool? ?? true,
      showBaseline: m['showBaseline'] as bool? ?? false,
      showResourceHistogram: m['showResourceHistogram'] as bool? ?? false,
      sidebarWidth: (m['sidebarWidth'] as num?)?.toDouble() ?? 260,
      autoScheduleEnabled: m['autoScheduleEnabled'] as bool? ?? false,
      swimlaneGroupBy: SwimlanGroupBy
          .values[swimIdx.clamp(0, SwimlanGroupBy.values.length - 1)],
    );
  }

  static Map<String, dynamic> _filterToMap(GanttFilter f) => {
        'searchQuery': f.searchQuery,
        'statuses': f.statuses.map((s) => s.index).toList(),
        'priorities': f.priorities.map((p) => p.index).toList(),
        'riskLevels': f.riskLevels.map((r) => r.index).toList(),
      };

  static GanttFilter _filterFromMap(Map<String, dynamic> m) => GanttFilter(
        searchQuery: m['searchQuery'] as String? ?? '',
        statuses: {
          for (final i in (m['statuses'] as List?)?.cast<int>() ?? [])
            if (i >= 0 && i < TaskStatus.values.length) TaskStatus.values[i]
        },
        priorities: {
          for (final i in (m['priorities'] as List?)?.cast<int>() ?? [])
            if (i >= 0 && i < TaskPriority.values.length) TaskPriority.values[i]
        },
        riskLevels: {
          for (final i in (m['riskLevels'] as List?)?.cast<int>() ?? [])
            if (i >= 0 && i < RiskLevel.values.length) RiskLevel.values[i]
        },
      );
}

// ─── Riverpod observer that auto-saves on every settings/filter change ─────────

class SettingsPersistenceObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider == viewSettingsProvider || provider == filterProvider) {
      _debouncedSave(container);
    }
  }

  static DateTime? _lastSave;
  static void _debouncedSave(ProviderContainer container) {
    final now = DateTime.now();
    if (_lastSave != null &&
        now.difference(_lastSave!) < const Duration(milliseconds: 500)) return;
    _lastSave = now;
    Future.delayed(const Duration(milliseconds: 400), () {
      try {
        final settings = container.read(viewSettingsProvider);
        final filter = container.read(filterProvider);
        PersistentSettings.save(settings, filter);
      } catch (_) {}
    });
  }
}
