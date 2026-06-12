// lib/main.dart
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: AssetTrackingApp()));
}

class AssetTrackingApp extends StatelessWidget {
  const AssetTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Tracker Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const DashboardView(),
    );
  }
}

// lib/theme/app_theme.dart

class AppTheme {
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2563EB),
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2563EB),
    brightness: Brightness.dark,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primaryContainer,
      foregroundColor: _lightColorScheme.onPrimaryContainer,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// lib/models/asset.dart
class Asset {
  final String id;
  final String name;
  final String category;
  final double purchaseValue;
  final DateTime purchaseDate;
  final int usefulLifeYears;
  final DepreciationMethod depreciationMethod;
  final String location;
  final String? assetTag;
  final String? notes;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.purchaseValue,
    required this.purchaseDate,
    required this.usefulLifeYears,
    required this.depreciationMethod,
    required this.location,
    this.assetTag,
    this.notes,
  });

  Asset copyWith({
    String? id,
    String? name,
    String? category,
    double? purchaseValue,
    DateTime? purchaseDate,
    int? usefulLifeYears,
    DepreciationMethod? depreciationMethod,
    String? location,
    String? assetTag,
    String? notes,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      usefulLifeYears: usefulLifeYears ?? this.usefulLifeYears,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
      location: location ?? this.location,
      assetTag: assetTag ?? this.assetTag,
      notes: notes ?? this.notes,
    );
  }

  // Calculate current value as of a specific date
  double currentValueAsOf(DateTime date) {
    if (date.isBefore(purchaseDate)) {
      return 0;
    }

    // Calculate depreciation
    return depreciationMethod.calculateValue(
      purchaseValue,
      purchaseDate,
      date,
      usefulLifeYears,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'purchaseValue': purchaseValue,
      'purchaseDate': purchaseDate.toIso8601String(),
      'usefulLifeYears': usefulLifeYears,
      'depreciationMethod': depreciationMethod.toString(),
      'location': location,
      'assetTag': assetTag,
      'notes': notes,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      purchaseValue: json['purchaseValue'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      usefulLifeYears: json['usefulLifeYears'],
      depreciationMethod: DepreciationMethod.values.firstWhere(
        (e) => e.toString() == json['depreciationMethod'],
        orElse: () => DepreciationMethod.straightLine,
      ),
      location: json['location'],
      assetTag: json['assetTag'],
      notes: json['notes'],
    );
  }
}

// lib/models/depreciation_method.dart
enum DepreciationMethod {
  straightLine,
  doubleDecliningBalance,
  sumOfYearsDigits,
  unitsOfProduction,
}

extension DepreciationMethodExtension on DepreciationMethod {
  String get displayName {
    switch (this) {
      case DepreciationMethod.straightLine:
        return 'Straight Line';
      case DepreciationMethod.doubleDecliningBalance:
        return 'Double Declining Balance';
      case DepreciationMethod.sumOfYearsDigits:
        return 'Sum of Years Digits';
      case DepreciationMethod.unitsOfProduction:
        return 'Units of Production';
    }
  }

  double calculateValue(
    double initialValue,
    DateTime purchaseDate,
    DateTime currentDate,
    int usefulLifeYears,
  ) {
    // Handle case where asset is not yet depreciated
    if (currentDate.isBefore(purchaseDate)) {
      return initialValue;
    }

    // Calculate age in years (can be fractional)
    final difference = currentDate.difference(purchaseDate);
    final ageInYears = difference.inDays / 365.25;

    // Asset is fully depreciated
    if (ageInYears >= usefulLifeYears) {
      return 0;
    }

    switch (this) {
      case DepreciationMethod.straightLine:
        return _calculateStraightLine(
          initialValue,
          ageInYears,
          usefulLifeYears,
        );
      case DepreciationMethod.doubleDecliningBalance:
        return _calculateDoubleDecliningBalance(
          initialValue,
          ageInYears,
          usefulLifeYears,
        );
      case DepreciationMethod.sumOfYearsDigits:
        return _calculateSumOfYearsDigits(
          initialValue,
          ageInYears,
          usefulLifeYears,
        );
      case DepreciationMethod.unitsOfProduction:
        // Default to straight line as units of production requires actual usage data
        return _calculateStraightLine(
          initialValue,
          ageInYears,
          usefulLifeYears,
        );
    }
  }

  double _calculateStraightLine(
    double initialValue,
    double ageInYears,
    int usefulLifeYears,
  ) {
    final depreciationRate = 1 / usefulLifeYears;
    final accumulatedDepreciation =
        initialValue * depreciationRate * ageInYears;
    return initialValue - accumulatedDepreciation;
  }

  double _calculateDoubleDecliningBalance(
    double initialValue,
    double ageInYears,
    int usefulLifeYears,
  ) {
    final rate = 2 / usefulLifeYears;
    double remainingValue = initialValue;

    for (int i = 0; i < ageInYears.floor(); i++) {
      remainingValue *= (1 - rate);
    }

    // Handle partial year
    if (ageInYears > ageInYears.floor()) {
      final partialYear = ageInYears - ageInYears.floor();
      remainingValue *= (1 - (rate * partialYear));
    }

    return remainingValue;
  }

  double _calculateSumOfYearsDigits(
    double initialValue,
    double ageInYears,
    int usefulLifeYears,
  ) {
    final sumOfYears = (usefulLifeYears * (usefulLifeYears + 1)) / 2;

    final fullYearsDepreciation = ageInYears.floor();
    double accumulatedDepreciation = 0;

    // Calculate depreciation for complete years
    for (int i = 0; i < fullYearsDepreciation; i++) {
      final yearFraction = (usefulLifeYears - i) / sumOfYears;
      accumulatedDepreciation += initialValue * yearFraction;
    }

    // Add partial year depreciation
    if (ageInYears > fullYearsDepreciation) {
      final partialYear = ageInYears - fullYearsDepreciation;
      final yearFraction =
          (usefulLifeYears - fullYearsDepreciation) / sumOfYears;
      accumulatedDepreciation += initialValue * yearFraction * partialYear;
    }

    return initialValue - accumulatedDepreciation;
  }
}

// lib/providers/asset_providers.dart

final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService();
});

final assetsProvider =
    StateNotifierProvider<AssetNotifier, AsyncValue<List<Asset>>>((ref) {
      final assetService = ref.watch(assetServiceProvider);
      return AssetNotifier(assetService);
    });

class AssetNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  final AssetService _assetService;

  AssetNotifier(this._assetService) : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    try {
      state = const AsyncValue.loading();
      final assets = await _assetService.getAssets();
      state = AsyncValue.data(assets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAsset(Asset asset) async {
    try {
      await _assetService.addAsset(asset);
      loadAssets();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateAsset(Asset asset) async {
    try {
      await _assetService.updateAsset(asset);
      loadAssets();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      await _assetService.deleteAsset(id);
      loadAssets();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Dashboard filter providers
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredAssetsProvider = Provider<AsyncValue<List<Asset>>>((ref) {
  final assetsAsync = ref.watch(assetsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final dateRange = ref.watch(dateRangeProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return assetsAsync.when(
    data: (assets) {
      return AsyncValue.data(
        assets.where((asset) {
          // Filter by category
          if (selectedCategory != null &&
              selectedCategory.isNotEmpty &&
              asset.category != selectedCategory) {
            return false;
          }

          // Filter by date range
          if (dateRange != null) {
            if (asset.purchaseDate.isBefore(dateRange.start) ||
                asset.purchaseDate.isAfter(dateRange.end)) {
              return false;
            }
          }

          // Filter by search query
          if (searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            return asset.name.toLowerCase().contains(query) ||
                asset.location.toLowerCase().contains(query) ||
                (asset.assetTag?.toLowerCase().contains(query) ?? false);
          }

          return true;
        }).toList(),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Calculate total asset values
final assetValueSummaryProvider = Provider<AsyncValue<AssetValueSummary>>((
  ref,
) {
  final assetsAsync = ref.watch(assetsProvider);

  return assetsAsync.when(
    data: (assets) {
      final now = DateTime.now();
      double totalOriginalValue = 0;
      double totalCurrentValue = 0;
      double totalDepreciation = 0;

      for (final asset in assets) {
        totalOriginalValue += asset.purchaseValue;
        final currentValue = asset.currentValueAsOf(now);
        totalCurrentValue += currentValue;
        totalDepreciation += (asset.purchaseValue - currentValue);
      }

      return AsyncValue.data(
        AssetValueSummary(
          totalOriginalValue: totalOriginalValue,
          totalCurrentValue: totalCurrentValue,
          totalDepreciation: totalDepreciation,
        ),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class AssetValueSummary {
  final double totalOriginalValue;
  final double totalCurrentValue;
  final double totalDepreciation;

  AssetValueSummary({
    required this.totalOriginalValue,
    required this.totalCurrentValue,
    required this.totalDepreciation,
  });

  double get depreciationPercentage => totalOriginalValue > 0
      ? (totalDepreciation / totalOriginalValue) * 100
      : 0;
}

// lib/services/asset_service.dart

class AssetService {
  static const String _storageKey = 'assets_data';

  // Get all assets
  Future<List<Asset>> getAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Asset.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Add a new asset
  Future<void> addAsset(Asset asset) async {
    final assets = await getAssets();
    assets.add(asset);
    await _saveAssets(assets);
  }

  // Update an existing asset
  Future<void> updateAsset(Asset updatedAsset) async {
    final assets = await getAssets();
    final index = assets.indexWhere((asset) => asset.id == updatedAsset.id);

    if (index >= 0) {
      assets[index] = updatedAsset;
      await _saveAssets(assets);
    }
  }

  // Delete an asset
  Future<void> deleteAsset(String id) async {
    final assets = await getAssets();
    assets.removeWhere((asset) => asset.id == id);
    await _saveAssets(assets);
  }

  // Save assets to storage
  Future<void> _saveAssets(List<Asset> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = assets.map((asset) => asset.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Generate sample assets for demo purposes
  Future<void> generateSampleAssets() async {
    final assets = await getAssets();

    if (assets.isEmpty) {
      final sampleAssets = [
        Asset(
          id: 'a001',
          name: 'Office Workstation',
          category: 'Furniture',
          purchaseValue: 2500.00,
          purchaseDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          usefulLifeYears: 7,
          depreciationMethod: DepreciationMethod.straightLine,
          location: 'Main Office',
          assetTag: 'FUR-001',
          notes: 'Includes desk, chair, and storage unit',
        ),
        Asset(
          id: 'a002',
          name: 'MacBook Pro',
          category: 'IT Equipment',
          purchaseValue: 3000.00,
          purchaseDate: DateTime.now().subtract(const Duration(days: 365)),
          usefulLifeYears: 4,
          depreciationMethod: DepreciationMethod.doubleDecliningBalance,
          location: 'Engineering Dept',
          assetTag: 'IT-238',
          notes: '16" model, 32GB RAM',
        ),
        Asset(
          id: 'a003',
          name: 'Conference Room Setup',
          category: 'Office Equipment',
          purchaseValue: 12000.00,
          purchaseDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
          usefulLifeYears: 10,
          depreciationMethod: DepreciationMethod.straightLine,
          location: 'Conference Room A',
          assetTag: 'OE-107',
          notes: 'Includes projector, sound system, and furniture',
        ),
      ];

      for (final asset in sampleAssets) {
        await addAsset(asset);
      }
    }
  }
}

// lib/views/dashboard_view.dart

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Generate sample data for demo purposes
    Future.microtask(() async {
      final assetService = ref.read(assetServiceProvider);
      await assetService.generateSampleAssets();
      ref.read(assetsProvider.notifier).loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = ref.watch(filteredAssetsProvider);
    final summary = ref.watch(assetValueSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Tracker Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar for large screens
          Container(
            width: 250,
            height: double.infinity,
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asset Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                _buildNavigationItem(
                  context,
                  'Dashboard',
                  Icons.dashboard,
                  true,
                  () {},
                ),
                _buildNavigationItem(
                  context,
                  'All Assets',
                  Icons.inventory_2,
                  false,
                  () {},
                ),
                _buildNavigationItem(
                  context,
                  'Categories',
                  Icons.category,
                  false,
                  () {},
                ),
                _buildNavigationItem(
                  context,
                  'Reports',
                  Icons.bar_chart,
                  false,
                  () {},
                ),
                _buildNavigationItem(
                  context,
                  'Settings',
                  Icons.settings,
                  false,
                  () {},
                ),
                const Spacer(),
                summary.when(
                  data: (data) => _buildSummaryCard(context, data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading summary'),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Asset Inventory',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Asset'),
                        onPressed: () => _navigateToAddAsset(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Statistics cards
                  summary.when(
                    data: (data) => _buildStatCards(context, data),
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const Text('Error loading statistics'),
                  ),

                  const SizedBox(height: 24),

                  // Assets table
                  Expanded(
                    child: filteredAssets.when(
                      data: (assets) => _buildAssetsTable(context, assets),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AssetValueSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Summary',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(summary.totalCurrentValue),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text('Current Value', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              '${summary.depreciationPercentage.toStringAsFixed(1)}% Depreciated',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, AssetValueSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Original Value'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(summary.totalOriginalValue),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.price_change,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Current Value'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(summary.totalCurrentValue),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_down,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      const Text('Total Depreciation'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(summary.totalDepreciation),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsTable(BuildContext context, List<Asset> assets) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');
    final now = DateTime.now();

    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Purchase Date')),
            DataColumn(label: Text('Original Value')),
            DataColumn(label: Text('Current Value')),
            DataColumn(label: Text('Depreciation')),
            DataColumn(label: Text('Actions')),
          ],
          rows: assets.map((asset) {
            final currentValue = asset.currentValueAsOf(now);
            final depreciationAmount = asset.purchaseValue - currentValue;
            final depreciationPercent =
                (depreciationAmount / asset.purchaseValue) * 100;

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(asset.category),
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(asset.name),
                    ],
                  ),
                  onTap: () => _navigateToAssetDetail(context, asset),
                ),
                DataCell(Text(asset.category)),
                DataCell(Text(dateFormat.format(asset.purchaseDate))),
                DataCell(Text(currencyFormat.format(asset.purchaseValue))),
                DataCell(Text(currencyFormat.format(currentValue))),
                DataCell(
                  Row(
                    children: [
                      Text('${depreciationPercent.toStringAsFixed(1)}%'),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 50,
                        child: LinearProgressIndicator(
                          value: depreciationPercent / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _navigateToEditAsset(context, asset),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _confirmDelete(context, asset),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'it equipment':
        return Icons.computer;
      case 'furniture':
        return Icons.chair;
      case 'office equipment':
        return Icons.business;
      case 'vehicles':
        return Icons.directions_car;
      case 'machinery':
        return Icons.precision_manufacturing;
      default:
        return Icons.inventory_2;
    }
  }

  void _navigateToAssetDetail(BuildContext context, Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetDetailView(asset: asset)),
    );
  }

  void _navigateToAddAsset(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssetFormView()),
    );
  }

  void _navigateToEditAsset(BuildContext context, Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetFormView(asset: asset)),
    );
  }

  void _confirmDelete(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete ${asset.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(assetsProvider.notifier).deleteAsset(asset.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Assets'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search by name, location, or tag',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final categories = [
      'IT Equipment',
      'Furniture',
      'Office Equipment',
      'Vehicles',
      'Machinery',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Assets'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: ref.watch(selectedCategoryProvider) == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                      }
                    },
                  ),
                  ...categories.map(
                    (category) => FilterChip(
                      label: Text(category),
                      selected: ref.watch(selectedCategoryProvider) == category,
                      onSelected: (selected) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            selected ? category : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Purchase Date Range:'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text('Select Date Range'),
                onPressed: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                    initialDateRange: ref.read(dateRangeProvider),
                  );

                  if (dateRange != null) {
                    ref.read(dateRangeProvider.notifier).state = dateRange;
                  }
                },
              ),
              if (ref.watch(dateRangeProvider) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'From: ${DateFormat('MMM d, yyyy').format(ref.watch(dateRangeProvider)!.start)} to '
                    '${DateFormat('MMM d, yyyy').format(ref.watch(dateRangeProvider)!.end)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              ref.read(dateRangeProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// lib/views/asset_detail_view.dart

class AssetDetailView extends ConsumerWidget {
  final Asset asset;

  const AssetDetailView({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');
    final now = DateTime.now();
    final currentValue = asset.currentValueAsOf(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditAsset(context),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel with asset details
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with basic info
                  Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _getCategoryIcon(asset.category),
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      asset.category,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    if (asset.assetTag != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Chip(
                                          label: Text(
                                            'Tag: ${asset.assetTag!}',
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.1),
                                          side: BorderSide.none,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildInfoItem(
                                context,
                                'Original Value',
                                currencyFormat.format(asset.purchaseValue),
                                Icons.monetization_on_outlined,
                              ),
                              const SizedBox(width: 24),
                              _buildInfoItem(
                                context,
                                'Current Value',
                                currencyFormat.format(currentValue),
                                Icons.price_change_outlined,
                              ),
                              const SizedBox(width: 24),
                              _buildInfoItem(
                                context,
                                'Purchase Date',
                                dateFormat.format(asset.purchaseDate),
                                Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Depreciation details
                  Text(
                    'Depreciation Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Method',
                                  asset.depreciationMethod.displayName,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Useful Life',
                                  '${asset.usefulLifeYears} years',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  'Depreciation to Date',
                                  '${((asset.purchaseValue - currentValue) / asset.purchaseValue * 100).toStringAsFixed(1)}%',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Visual representation of depreciation
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Depreciation Progress',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value:
                                      (asset.purchaseValue - currentValue) /
                                      asset.purchaseValue,
                                  minHeight: 16,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currencyFormat.format(currentValue),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      currencyFormat.format(
                                        asset.purchaseValue - currentValue,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Current Value',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Depreciated',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional details
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(context, 'Location', asset.location),
                          const Divider(),
                          _buildDetailItem(
                            context,
                            'Notes',
                            asset.notes ?? 'No additional notes',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel with depreciation chart
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Depreciation Forecast',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: DepreciationChart(asset: asset)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  void _navigateToEditAsset(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetFormView(asset: asset)),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'it equipment':
        return Icons.computer;
      case 'furniture':
        return Icons.chair;
      case 'office equipment':
        return Icons.business;
      case 'vehicles':
        return Icons.directions_car;
      case 'machinery':
        return Icons.precision_manufacturing;
      default:
        return Icons.inventory_2;
    }
  }
}

// lib/views/asset_form_view.dart

class AssetFormView extends ConsumerStatefulWidget {
  final Asset? asset;

  const AssetFormView({super.key, this.asset});

  @override
  ConsumerState<AssetFormView> createState() => _AssetFormViewState();
}

class _AssetFormViewState extends ConsumerState<AssetFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _purchaseValueController;
  late final TextEditingController _usefulLifeController;
  late final TextEditingController _locationController;
  late final TextEditingController _assetTagController;
  late final TextEditingController _notesController;

  late String _selectedCategory;
  late DateTime _purchaseDate;
  late DepreciationMethod _depreciationMethod;

  final List<String> _categories = [
    'IT Equipment',
    'Furniture',
    'Office Equipment',
    'Vehicles',
    'Machinery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final asset = widget.asset;

    _nameController = TextEditingController(text: asset?.name ?? '');
    _purchaseValueController = TextEditingController(
      text: asset?.purchaseValue.toString() ?? '',
    );
    _usefulLifeController = TextEditingController(
      text: asset?.usefulLifeYears.toString() ?? '',
    );
    _locationController = TextEditingController(text: asset?.location ?? '');
    _assetTagController = TextEditingController(text: asset?.assetTag ?? '');
    _notesController = TextEditingController(text: asset?.notes ?? '');

    _selectedCategory = asset?.category ?? _categories.first;
    _purchaseDate = asset?.purchaseDate ?? DateTime.now();
    _depreciationMethod =
        asset?.depreciationMethod ?? DepreciationMethod.straightLine;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseValueController.dispose();
    _usefulLifeController.dispose();
    _locationController.dispose();
    _assetTagController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.asset != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Asset' : 'Add New Asset')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            Expanded(
              flex: 2,
              child: Form(
                key: _formKey,
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asset Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),

                        // Basic info
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Asset Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter asset name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedCategory,
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter location';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _assetTagController,
                          decoration: const InputDecoration(
                            labelText: 'Asset Tag (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Valuation & Depreciation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _purchaseValueController,
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Value',
                                  prefixText: '\$ ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter purchase value';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _selectPurchaseDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Date',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(_purchaseDate),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  DropdownButtonFormField<DepreciationMethod>(
                                    decoration: const InputDecoration(
                                      labelText: 'Depreciation Method',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _depreciationMethod,
                                    items: DepreciationMethod.values.map((
                                      method,
                                    ) {
                                      return DropdownMenuItem(
                                        value: method,
                                        child: Text(method.displayName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _depreciationMethod = value;
                                        });
                                      }
                                    },
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _usefulLifeController,
                                decoration: const InputDecoration(
                                  labelText: 'Useful Life (Years)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter useful life';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Additional Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          minLines: 3,
                          maxLines: 5,
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _saveAsset,
                              child: Text(
                                isEditing ? 'Update Asset' : 'Add Asset',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Preview
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildPreview(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Widget _buildPreview(BuildContext context) {
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'Asset Name';
    final purchaseValueText = _purchaseValueController.text;
    final purchaseValue = double.tryParse(purchaseValueText) ?? 0.0;
    final usefulLifeText = _usefulLifeController.text;
    final usefulLife = int.tryParse(usefulLifeText) ?? 0;

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    final previewAsset = Asset(
      id: widget.asset?.id ?? '',
      name: name,
      category: _selectedCategory,
      purchaseValue: purchaseValue,
      purchaseDate: _purchaseDate,
      usefulLifeYears: usefulLife,
      depreciationMethod: _depreciationMethod,
      location: _locationController.text,
      assetTag: _assetTagController.text.isEmpty
          ? null
          : _assetTagController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final now = DateTime.now();
    final currentValue = previewAsset.currentValueAsOf(now);
    final depreciationAmount = purchaseValue - currentValue;
    final depreciationPercent = purchaseValue > 0
        ? (depreciationAmount / purchaseValue) * 100
        : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              _getCategoryIcon(_selectedCategory),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(name),
            subtitle: Text(_selectedCategory),
          ),
          const Divider(),
          _buildPreviewItem(
            context,
            'Purchase Value',
            purchaseValue > 0
                ? currencyFormat.format(purchaseValue)
                : 'Not specified',
          ),
          _buildPreviewItem(
            context,
            'Purchase Date',
            DateFormat('MMM d, yyyy').format(_purchaseDate),
          ),
          _buildPreviewItem(
            context,
            'Depreciation Method',
            _depreciationMethod.displayName,
          ),
          _buildPreviewItem(
            context,
            'Useful Life',
            usefulLife > 0 ? '$usefulLife years' : 'Not specified',
          ),
          const Divider(),
          _buildPreviewItem(
            context,
            'Current Value (Estimated)',
            purchaseValue > 0 && usefulLife > 0
                ? currencyFormat.format(currentValue)
                : 'Insufficient data',
          ),
          if (purchaseValue > 0 && usefulLife > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Depreciation Progress',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: depreciationPercent / 100,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${depreciationPercent.toStringAsFixed(1)}% depreciated',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _saveAsset() {
    if (_formKey.currentState?.validate() ?? false) {
      final assetNotifier = ref.read(assetsProvider.notifier);

      final purchaseValue = double.parse(_purchaseValueController.text);
      final usefulLife = int.parse(_usefulLifeController.text);

      final asset = Asset(
        id: widget.asset?.id ?? const Uuid().v4(),
        name: _nameController.text,
        category: _selectedCategory,
        purchaseValue: purchaseValue,
        purchaseDate: _purchaseDate,
        usefulLifeYears: usefulLife,
        depreciationMethod: _depreciationMethod,
        location: _locationController.text,
        assetTag: _assetTagController.text.isEmpty
            ? null
            : _assetTagController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.asset != null) {
        assetNotifier.updateAsset(asset);
      } else {
        assetNotifier.addAsset(asset);
      }

      Navigator.pop(context);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'it equipment':
        return Icons.computer;
      case 'furniture':
        return Icons.chair;
      case 'office equipment':
        return Icons.business;
      case 'vehicles':
        return Icons.directions_car;
      case 'machinery':
        return Icons.precision_manufacturing;
      default:
        return Icons.inventory_2;
    }
  }
}

// lib/views/widgets/depreciation_chart.dart

class DepreciationChart extends StatelessWidget {
  final Asset asset;

  const DepreciationChart({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    // Generate data points for the chart
    final dataPoints = _generateDepreciationData();
    final maxY = asset.purchaseValue * 1.1;

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 24),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: asset.purchaseValue / 5,
            verticalInterval: 1,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: asset.purchaseValue / 5,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '\$${(value / 1000).toStringAsFixed(1)}k',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  if (value % 2 != 0 && value != dataPoints.length - 1) {
                    return const SizedBox.shrink();
                  }
                  final year = asset.purchaseDate.year + value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            // Historical value line
            LineChartBarData(
              spots: dataPoints,
              isCurved: false,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Current date indicator
            LineChartBarData(
              spots: _getCurrentDateIndicator(dataPoints),
              isCurved: false,
              color: Theme.of(context).colorScheme.tertiary,
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Theme.of(context).colorScheme.tertiary,
                    strokeWidth: 1,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Theme.of(context).colorScheme.surface,
              tooltipRoundedRadius: 8,
              tooltipBorder: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final year = asset.purchaseDate.year + spot.x.toInt();
                  final value = spot.y;
                  return LineTooltipItem(
                    '$year\n${NumberFormat.currency(symbol: '\$').format(value)}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateDepreciationData() {
    final spots = <FlSpot>[];
    final purchaseYear = asset.purchaseDate.year;

    // Add data point for purchase date (Year 0)
    spots.add(const FlSpot(0, 0)); // This will be replaced

    // Generate points for each year of useful life plus a few more
    for (int year = 0; year <= asset.usefulLifeYears + 2; year++) {
      final dateForValue = DateTime(
        purchaseYear + year,
        asset.purchaseDate.month,
        asset.purchaseDate.day,
      );
      final value = asset.currentValueAsOf(dateForValue);
      spots.add(FlSpot(year.toDouble(), value));
    }

    // Remove the first placeholder point
    spots.removeAt(0);

    return spots;
  }

  List<FlSpot> _getCurrentDateIndicator(List<FlSpot> dataPoints) {
    final now = DateTime.now();
    final yearsDifference = now.difference(asset.purchaseDate).inDays / 365.25;

    // Find the closest data points
    if (yearsDifference < 0) return [];

    if (yearsDifference >= dataPoints.length - 1) {
      return [dataPoints.last];
    }

    final lowerIndex = yearsDifference.floor();
    final upperIndex = yearsDifference.ceil();

    if (lowerIndex == upperIndex) {
      return [dataPoints[lowerIndex]];
    }

    // Interpolate between points
    final lowerValue = dataPoints[lowerIndex].y;
    final upperValue = dataPoints[upperIndex].y;

    final fraction = yearsDifference - lowerIndex;
    final interpolatedValue = lowerValue + (upperValue - lowerValue) * fraction;

    return [FlSpot(yearsDifference, interpolatedValue)];
  }
}
