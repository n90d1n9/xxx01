/// Chart type registry — the foundation for tree-shakeable chart inclusion.
///
/// ## Problem with the current approach
///
/// `helper.dart` contains a `getChartConfig()` switch that imports every
/// chart config class directly:
/// ```dart
/// import 'bar/bar_chart_config.dart';
/// import 'line/line_chart_config.dart';
/// import 'sankey/sankey_config.dart';     // ← pulled in even if never used
/// import 'treemap/treemap_chart.dart';    // ← same
/// // ... 30+ more imports
/// ```
/// Because Dart's tree shaker can only eliminate code that is **never
/// referenced**, and every config is referenced in the switch, **every chart
/// type always ends up in the binary**, even when the app only uses bar + line.
///
/// ## Solution — Registry pattern
///
/// Each chart type registers a lightweight factory closure. The registry is
/// the only file that needs to exist in the core library. Individual chart
/// packages register themselves when their `init()` is called.
///
/// Dart tree shaker will then drop any chart type whose `init()` is never
/// called — its code is simply never referenced from a reachable code path.
///
/// ## Usage
///
/// ### App bootstrapping (registers only the charts you need):
/// ```dart
/// void main() {
///   // Register only the chart types your app uses.
///   ChartRegistry.register(CoreCharts.bar);
///   ChartRegistry.register(CoreCharts.line);
///   ChartRegistry.register(CoreCharts.pie);
///   // Advanced charts: only included if registered.
///   // ChartRegistry.register(AdvancedCharts.sankey);
///
///   runApp(const MyApp());
/// }
/// ```
///
/// ### Registering a bundle:
/// ```dart
/// ChartRegistry.registerAll(CoreCharts.all);      // bar, line, pie, scatter
/// ChartRegistry.registerAll(AdvancedCharts.all);  // sankey, treemap, etc.
/// ```
///
/// ### From JSON (unchanged API for consumers):
/// ```dart
/// TenunChart(jsonConfig: {'type': 'bar', 'series': [...] })
/// // → internally calls ChartRegistry.resolve('bar', json)
/// ```
///
/// ## Defining a chart registration:
/// ```dart
/// // In bar_chart_config.dart (or a separate registration file):
/// final barChartRegistration = ChartRegistration(
///   type: ChartType.bar,
///   typeString: 'bar',
///   aliases: ['vertical_bar'],
///   fromJson: BarChartConfig.fromJson,
/// );
/// ```
library chart_registry;

import 'chart_type.dart';
import 'base_config.dart';

// ---------------------------------------------------------------------------
// ChartRegistration — metadata for one chart type
// ---------------------------------------------------------------------------

/// Describes one registered chart type.
class ChartRegistration {
  /// The canonical [ChartType] enum value.
  final ChartType type;

  /// Primary string key (matches [chartTypeToString]).
  final String typeString;

  /// Optional aliases (e.g. `['vertical_bar', 'column']` for `ChartType.bar`).
  final List<String> aliases;

  /// Factory that deserialises a [BaseChartConfig] from JSON.
  final BaseChartConfig Function(Map<String, dynamic> json) fromJson;

  /// Human-readable description (used for tooling / documentation).
  final String description;

  /// Feature tags for discovery (e.g. `['statistical', 'timeseries']`).
  final List<String> tags;

  const ChartRegistration({
    required this.type,
    required this.typeString,
    required this.fromJson,
    this.aliases = const [],
    this.description = '',
    this.tags = const [],
  });
}

// ---------------------------------------------------------------------------
// ChartRegistry
// ---------------------------------------------------------------------------

/// Global registry of chart types.
///
/// This is the **single** place that maps chart type strings → config
/// factories. The monolithic `getChartConfig` switch in `helper.dart`
/// is replaced by calls to [ChartRegistry.resolve].
class ChartRegistry {
  ChartRegistry._();

  /// Map from canonical type string → registration.
  static final Map<String, ChartRegistration> _byString = {};

  /// Map from [ChartType] enum → registration.
  static final Map<ChartType, ChartRegistration> _byType = {};

  // ---------- Registration ----------

  /// Register a single chart type.
  ///
  /// Idempotent — re-registering the same type is a no-op.
  static void register(ChartRegistration reg) {
    _byType[reg.type] = reg;
    _byString[reg.typeString.toLowerCase()] = reg;
    for (final alias in reg.aliases) {
      _byString[alias.toLowerCase()] = reg;
    }
  }

  /// Register multiple chart types at once.
  static void registerAll(Iterable<ChartRegistration> registrations) {
    for (final reg in registrations) {
      register(reg);
    }
  }

  /// Remove a chart type from the registry (e.g. for testing).
  static void unregister(ChartType type) {
    final reg = _byType.remove(type);
    if (reg != null) {
      _byString.remove(reg.typeString.toLowerCase());
      for (final alias in reg.aliases) {
        _byString.remove(alias.toLowerCase());
      }
    }
  }

  /// Clear all registrations (use in tests only).
  static void clear() {
    _byType.clear();
    _byString.clear();
  }

  // ---------- Resolution ----------

  /// Resolve a [BaseChartConfig] from a JSON map.
  ///
  /// Looks up `json['type']` in the registry. Throws [UnregisteredChartTypeException]
  /// if the type has not been registered.
  ///
  /// This replaces the `getChartConfig()` switch in `helper.dart`.
  static BaseChartConfig resolve(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? '').trim().toLowerCase();
    final reg = _byString[typeStr];
    if (reg == null) {
      throw UnregisteredChartTypeException(typeStr, registeredTypes);
    }
    return reg.fromJson(json);
  }

  /// Resolve by [ChartType] enum (convenience — avoids string lookup).
  static BaseChartConfig resolveByType(
    ChartType type,
    Map<String, dynamic> json,
  ) {
    final reg = _byType[type];
    if (reg == null) {
      throw UnregisteredChartTypeException(
        chartTypeToString(type),
        registeredTypes,
      );
    }
    return reg.fromJson(json);
  }

  // ---------- Introspection ----------

  /// True if [type] has been registered.
  static bool isRegistered(ChartType type) => _byType.containsKey(type);

  /// True if type string [s] has been registered.
  static bool isRegisteredString(String s) =>
      _byString.containsKey(s.toLowerCase());

  /// All currently registered type strings.
  static List<String> get registeredTypes =>
      _byString.keys.toList(growable: false);

  /// All registered [ChartType] enum values.
  static List<ChartType> get registeredEnums =>
      _byType.keys.toList(growable: false);

  /// All registrations with a given tag.
  static List<ChartRegistration> withTag(String tag) =>
      _byType.values.where((r) => r.tags.contains(tag)).toList();

  /// Number of registered chart types.
  static int get count => _byType.length;
}

// ---------------------------------------------------------------------------
// UnregisteredChartTypeException
// ---------------------------------------------------------------------------

class UnregisteredChartTypeException implements Exception {
  final String requestedType;
  final List<String> availableTypes;

  const UnregisteredChartTypeException(this.requestedType, this.availableTypes);

  @override
  String toString() =>
      'UnregisteredChartTypeException: Chart type "$requestedType" is not '
      'registered. Did you forget to call ChartRegistry.register() in main()?\n'
      'Registered types: ${availableTypes.join(', ')}';
}

// ---------------------------------------------------------------------------
// RegistrationBundle — groups related chart registrations
// ---------------------------------------------------------------------------

/// A named group of [ChartRegistration] objects.
///
/// Bundles are the unit of optional inclusion — register a whole bundle
/// to pull in a category of charts:
/// ```dart
/// ChartRegistry.registerAll(CoreCharts.bundle);
/// ChartRegistry.registerAll(TradingCharts.bundle);
/// ```
class RegistrationBundle {
  final String name;
  final String description;
  final List<ChartRegistration> registrations;

  const RegistrationBundle({
    required this.name,
    required this.description,
    required this.registrations,
  });

  /// Register all charts in this bundle.
  void register() => ChartRegistry.registerAll(registrations);
}

// ---------------------------------------------------------------------------
// Built-in bundle definitions (no imports — registration files import these)
// ---------------------------------------------------------------------------

// NOTE: The actual ChartRegistration instances are defined alongside their
// chart configs (e.g. `bar_chart_config.dart` exports `barChartRegistration`).
// Bundle files just collect them:
//
//   // lib/charts/core/core_charts_bundle.dart
//   import '../bar/bar_chart_config.dart' show barChartRegistration;
//   import '../line/line_chart_config.dart' show lineChartRegistration;
//   ...
//
//   const coreChartsBundle = RegistrationBundle(
//     name: 'core',
//     description: 'Bar, line, area, pie, donut, scatter',
//     registrations: [
//       barChartRegistration,
//       lineChartRegistration,
//       areaChartRegistration,
//       pieChartRegistration,
//       donutChartRegistration,
//       scatterChartRegistration,
//     ],
//   );
//
// The app then only imports the bundle files it needs, and Dart tree-shakes
// everything else.
