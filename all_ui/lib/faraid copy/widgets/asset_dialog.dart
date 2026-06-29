import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/assets.dart';
import '../models/family_tree_state.dart';
import '../states/family_tree_provider.dart';

class AssetsDialog extends ConsumerStatefulWidget {
  const AssetsDialog({super.key});

  @override
  ConsumerState<AssetsDialog> createState() => _AssetsDialogState();
}

class _AssetsDialogState extends ConsumerState<AssetsDialog> {
  int _currentTabIndex = 0;
  final List<String> _categories = [
    'Property',
    'Uang Tunai',
    'Investasi',
    'Kendaraan',
    'Perhiasan',
    'Logam Mulia',
    'Saham',
    'Deposito',
    'Lain-lain',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyTreeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengelolaan Harta & Kewajiban',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Tab Indicators
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton('Aset/Harta', 0),
                  _buildTabButton('Hutang', 1),
                  _buildTabButton('Pengeluaran', 2),
                  _buildTabButton('Wasiat', 3),
                  _buildTabButton('Ringkasan', 4),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content based on selected tab
            Expanded(child: _buildCurrentTab(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(FamilyTreeState state) {
    switch (_currentTabIndex) {
      case 0:
        return _buildAssetsTab(state);
      case 1:
        return _buildDebtsTab(state);
      case 2:
        return _buildExpensesTab(state);
      case 3:
        return _buildBequestsTab(state);
      case 4:
        return _buildSummaryTab(state);
      default:
        return _buildAssetsTab(state);
    }
  }

  Map<String, List<Asset>> _groupAssetsByCategory(List<Asset> assets) {
    final map = <String, List<Asset>>{};
    for (final asset in assets) {
      map.putIfAbsent(asset.category, () => []).add(asset);
    }
    return map;
  }

  double _calculateLiquidAssets(List<Asset> assets) {
    return assets
        .where((asset) => asset.isLiquid)
        .fold(0.0, (sum, asset) => sum + asset.currentValue);
  }

  double _calculateIlliquidAssets(List<Asset> assets) {
    return assets
        .where((asset) => !asset.isLiquid)
        .fold(0.0, (sum, asset) => sum + asset.currentValue);
  }

  Widget _buildAssetCategorySection(String category, List<Asset> assets) {
    final totalCategoryValue = assets.fold(
      0.0,
      (sum, asset) => sum + asset.currentValue,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: _getCategoryIcon(category),
            title: Text(category),
            trailing: Text(
              '\$${totalCategoryValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...assets.map((asset) => _buildAssetTile(asset)),
        ],
      ),
    );
  }

  Widget _buildAssetsTab(FamilyTreeState state) {
    final assetsByCategory = _groupAssetsByCategory(state.estate.assets);
    final totalLiquid = _calculateLiquidAssets(state.estate.assets);
    final totalIlliquid = _calculateIlliquidAssets(state.estate.assets);

    return Column(
      children: [
        // Summary Cards
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSummaryCard(
                'Total Harta',
                '\$${state.estate.totalAssets.toStringAsFixed(2)}',
                Colors.green,
                Icons.account_balance_wallet,
                'Semua aset',
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'Harta Liquid',
                '\$${totalLiquid.toStringAsFixed(2)}',
                Colors.blue,
                Icons.attach_money,
                'Mudah dicairkan',
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'Harta Tidak Liquid',
                '\$${totalIlliquid.toStringAsFixed(2)}',
                Colors.orange,
                Icons.home_work,
                'Sulit dicairkan',
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'Jumlah Aset',
                '${state.estate.assets.length}',
                Colors.purple,
                Icons.inventory_2,
                'Total item',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search and Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari aset...',
                      border: InputBorder.none,
                      icon: const Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (category) {
                  // Implement filter by category
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('Semua Kategori'),
                      ),
                      const PopupMenuDivider(),
                      ..._categories
                          .map(
                            (category) => PopupMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                    ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Assets List
        Expanded(
          child:
              state.estate.assets.isEmpty
                  ? _buildEmptyState(
                    'Belum ada aset',
                    'Tambahkan aset untuk memulai perhitungan warisan',
                    Icons.inventory_2,
                    () => _showAddAssetDialog(context),
                  )
                  : ListView(
                    children: [
                      ...assetsByCategory.entries.map(
                        (entry) =>
                            _buildAssetCategorySection(entry.key, entry.value),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildDebtsTab(FamilyTreeState state) {
    final totalDebts = state.estate.totalDebts;

    return Column(
      children: [
        _buildSummaryCard(
          'Total Hutang',
          '\$${totalDebts.toStringAsFixed(2)}',
          Colors.red,
          Icons.credit_card,
          'Kewajiban yang harus dibayar',
        ),
        const SizedBox(height: 16),

        if (totalDebts > 0) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Hutang akan diprioritaskan untuk dibayar sebelum pembagian warisan',
              style: TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        Expanded(
          child: _buildEmptyState(
            'Manajemen Hutang',
            'Tambahkan hutang untuk perhitungan yang akurat',
            Icons.credit_card,
            () => _showAddDebtDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab(FamilyTreeState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Biaya Pemakaman',
                '\$${state.estate.funeralExpenses.toStringAsFixed(2)}',
                Colors.orange,
                Icons.medical_services,
                'Biaya pengurusan jenazah',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Biaya Administrasi',
                '\$${state.estate.administrativeCosts.toStringAsFixed(2)}',
                Colors.purple,
                Icons.admin_panel_settings,
                'Biaya administrasi warisan',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _buildEmptyState(
            'Manajemen Pengeluaran',
            'Atur biaya pemakaman dan administrasi',
            Icons.receipt,
            () => _showEditExpensesDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBequestsTab(FamilyTreeState state) {
    final maxBequests =
        (state.estate.totalAssets -
            state.estate.totalDebts -
            state.estate.totalExpenses) *
        (1 / 3);
    final currentBequests = state.estate.bequests.fold(
      0.0,
      (sum, bequest) => sum + bequest.amount,
    );

    return Column(
      children: [
        _buildSummaryCard(
          'Maksimal Wasiat (1/3)',
          '\$${maxBequests.toStringAsFixed(2)}',
          Colors.teal,
          Icons.assignment,
          'Batas maksimal wasiat',
        ),
        const SizedBox(height: 8),

        if (currentBequests > 0) ...[
          _buildSummaryCard(
            'Wasiat Saat Ini',
            '\$${currentBequests.toStringAsFixed(2)}',
            currentBequests <= maxBequests ? Colors.green : Colors.red,
            Icons.assignment_turned_in,
            currentBequests <= maxBequests ? 'Wasiat valid' : 'Melebihi batas',
          ),
          const SizedBox(height: 8),
        ],

        if (currentBequests > maxBequests) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wasiat melebihi batas 1/3. Harus dikurangi sebesar \$${(currentBequests - maxBequests).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Expanded(
          child: _buildEmptyState(
            'Manajemen Wasiat',
            'Tambahkan wasiat (maksimal 1/3 dari harta bersih)',
            Icons.assignment,
            () => _showAddBequestDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab(FamilyTreeState state) {
    final netEstate = state.estate.netEstate;
    final isSolvent = netEstate >= 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Net Estate Card
          Card(
            color: isSolvent ? Colors.green[50] : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'HARTA BERSIH WARISAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSolvent ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${netEstate.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isSolvent ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSolvent
                        ? 'Harta cukup untuk pembagian warisan'
                        : 'Harta tidak cukup untuk melunasi kewajiban',
                    style: TextStyle(
                      color: isSolvent ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Breakdown
          _buildBreakdownItem(
            'Total Aset',
            state.estate.totalAssets,
            Colors.green,
          ),
          _buildBreakdownItem(
            'Total Hutang',
            state.estate.totalDebts,
            Colors.red,
            isNegative: true,
          ),
          _buildBreakdownItem(
            'Total Pengeluaran',
            state.estate.totalExpenses,
            Colors.orange,
            isNegative: true,
          ),
          _buildBreakdownItem(
            'Total Wasiat',

            /*       state.estate.legacyBequests.values.fold(
              0.0,
              (sum, val) => sum + val,
            ) */
            state.estate.bequests.fold(
              0.0,
              (sum, bequest) => sum + bequest.amount,
            ),
            Colors.teal,
            isNegative: true,
          ),

          const Divider(),
          _buildBreakdownItem(
            'HARTA BERSIH',
            netEstate,
            isSolvent ? Colors.green : Colors.red,
            isTotal: true,
          ),

          const SizedBox(height: 16),

          // Distribution Info
          if (isSolvent && netEstate > 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pembagian:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDistributionInfo(
                      'Harta bersih tersedia untuk pembagian warisan Islam (Faraid)',
                    ),
                    _buildDistributionInfo(
                      'Wasiat maksimal 1/3 dari harta bersih',
                    ),
                    _buildDistributionInfo(
                      'Hutang dan biaya pemakaman diprioritaskan',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    double value,
    Color color, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAdd,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Property':
        return const Icon(Icons.home);
      case 'Uang Tunai':
        return const Icon(Icons.attach_money);
      case 'Investasi':
        return const Icon(Icons.trending_up);
      case 'Kendaraan':
        return const Icon(Icons.directions_car);
      case 'Perhiasan':
        return const Icon(Icons.diamond);
      default:
        return const Icon(Icons.category);
    }
  }
  /* 
  Widget _buildAssetCategorySection(String category, List<Asset> assets) {
    final totalCategoryValue = assets.fold(
      0.0,
      (sum, asset) => sum + asset.currentValue,
    );
    final liquidAssets = assets.where((a) => a.isLiquid).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: _getCategoryIcon(category),
            title: Text(category),
            subtitle: Text('${assets.length} aset • $liquidAssets liquid'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalCategoryValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${((totalCategoryValue / state.estate.totalAssets) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ...assets.map((asset) => _buildAssetTile(asset)),
        ],
      ),
    );
  } */

  Widget _buildAssetTile(Asset asset) {
    final appreciation = asset.currentValue - asset.value;
    final appreciationPercent =
        asset.value > 0 ? (appreciation / asset.value) * 100 : 0;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              asset.isLiquid
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(asset.category).icon,
          size: 20,
          color: asset.isLiquid ? Colors.blue : Colors.orange,
        ),
      ),
      title: Text(
        asset.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(asset.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (appreciation > 0) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.trending_up, size: 12, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '+\$${appreciation.toStringAsFixed(2)} (${appreciationPercent.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
          if (asset.acquisitionDate != null) ...[
            const SizedBox(height: 2),
            Text(
              'Diperoleh: ${DateFormat('dd/MM/yyyy').format(asset.acquisitionDate!)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ],
      ),
      trailing: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${asset.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!asset.isLiquid)
                  const Icon(Icons.lock_clock, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  asset.isLiquid ? 'Liquid' : 'Tidak Liquid',
                  style: TextStyle(
                    fontSize: 10,
                    color: asset.isLiquid ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () => _showEditAssetDialog(context, asset),
      onLongPress: () => _showAssetActions(context, asset),
    );
  }

  void _showAssetActions(BuildContext context, Asset asset) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Aset'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditAssetDialog(context, asset);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus Aset',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteAsset(context, asset);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Duplikat Aset'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _duplicateAsset(context, asset);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _duplicateAsset(BuildContext context, Asset asset) {
    final newAsset = asset.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${asset.name} (Salinan)',
    );
    ref.read(familyTreeProvider.notifier).addAsset(newAsset);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aset "${asset.name}" telah diduplikasi')),
    );
  }

  // ... (Keep the existing _getCategoryIcon method)

  void _showAddAssetDialog(BuildContext context) {
    _showAssetDialog(context, null);
  }

  void _showEditAssetDialog(BuildContext context, Asset asset) {
    _showAssetDialog(context, asset);
  }

  void _showAssetDialog(BuildContext context, Asset? existingAsset) {
    final nameController = TextEditingController(
      text: existingAsset?.name ?? '',
    );
    final descController = TextEditingController(
      text: existingAsset?.description ?? '',
    );
    final valueController = TextEditingController(
      text: existingAsset?.value.toString() ?? '',
    );
    final appreciationController = TextEditingController(
      text: ((existingAsset?.appreciationRate ?? 0.0) * 100).toStringAsFixed(1),
    );

    String category = existingAsset?.category ?? 'Property';
    bool isLiquid = existingAsset?.isLiquid ?? true;
    DateTime? acquisitionDate = existingAsset?.acquisitionDate;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: Text(
                    existingAsset == null ? 'Tambah Aset' : 'Edit Aset',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Aset *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: valueController,
                          decoration: const InputDecoration(
                            labelText: 'Nilai Awal *',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: appreciationController,
                          decoration: const InputDecoration(
                            labelText: 'Tingkat Apresiasi Tahunan (%)',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                            hintText: '0.0',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setDialogState(() => category = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Aset Liquid (mudah dicairkan)'),
                          subtitle: const Text(
                            'Contoh: uang tunai, tabungan, deposito',
                          ),
                          value: isLiquid,
                          onChanged:
                              (val) =>
                                  setDialogState(() => isLiquid = val ?? false),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Tanggal Perolehan'),
                          subtitle: Text(
                            acquisitionDate != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(acquisitionDate!)
                                : 'Pilih tanggal (opsional)',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() => acquisitionDate = date);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    if (existingAsset != null)
                      TextButton(
                        onPressed: () {
                          _confirmDeleteAsset(context, existingAsset);
                          Navigator.pop(ctx);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty &&
                            valueController.text.isNotEmpty) {
                          final asset = Asset(
                            id:
                                existingAsset?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            value: double.tryParse(valueController.text) ?? 0.0,
                            category: category,
                            acquisitionDate: acquisitionDate,
                            isLiquid: isLiquid,
                            appreciationRate:
                                (double.tryParse(appreciationController.text) ??
                                    0.0) /
                                100,
                          );

                          if (existingAsset == null) {
                            ref
                                .read(familyTreeProvider.notifier)
                                .addAsset(asset);
                          } else {
                            ref
                                .read(familyTreeProvider.notifier)
                                .updateAsset(asset);
                          }

                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(existingAsset == null ? 'Tambah' : 'Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _confirmDeleteAsset(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Aset'),
            content: Text(
              'Hapus aset "${asset.name}" senilai \$${asset.currentValue.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(familyTreeProvider.notifier).removeAsset(asset.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Aset "${asset.name}" telah dihapus'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // Placeholder methods for other dialogs
  void _showAddDebtDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur manajemen hutang akan segera hadir')),
    );
  }

  void _showEditExpensesDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur manajemen pengeluaran akan segera hadir'),
      ),
    );
  }

  void _showAddBequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur manajemen wasiat akan segera hadir')),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double value,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
