// promotion_types.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

enum PromotionType {
  DISCOUNT,
  COUPON,
  POINT,
  BOGO,
  LOYALTY,
  BUNDLING,
  CUSTOMIZE,
  LIFESTYLE,
  FLASH_SALE,
  GIVEAWAY,
  FREE_SHIPPING,
  FREE_SAMPLES,
  FREE_GIFT,
  HOLIDAY,
}

class PromotionData {
  final PromotionType type;
  final String idLabel;
  final String enLabel;
  final IconData icon;

  const PromotionData({
    required this.type,
    required this.idLabel,
    required this.enLabel,
    required this.icon,
  });
}

final promotionsData = {
  PromotionType.DISCOUNT: PromotionData(
    type: PromotionType.DISCOUNT,
    idLabel: "Diskon",
    enLabel: "Discount",
    icon: Icons.discount,
  ),
  PromotionType.COUPON: PromotionData(
    type: PromotionType.COUPON,
    idLabel: "Kupon",
    enLabel: "Coupons",
    icon: Icons.confirmation_number,
  ),
  PromotionType.POINT: PromotionData(
    type: PromotionType.POINT,
    idLabel: "Poin",
    enLabel: "Point Achievement",
    icon: Icons.stars,
  ),
  PromotionType.BOGO: PromotionData(
    type: PromotionType.BOGO,
    idLabel: "BOGO",
    enLabel: "Buy One Get One",
    icon: Icons.card_giftcard,
  ),
  PromotionType.LOYALTY: PromotionData(
    type: PromotionType.LOYALTY,
    idLabel: "Loyalitas",
    enLabel: "Loyalty Member Discount",
    icon: Icons.loyalty,
  ),
  PromotionType.BUNDLING: PromotionData(
    type: PromotionType.BUNDLING,
    idLabel: "Paket Bundling",
    enLabel: "Bundling",
    icon: Icons.inventory_2,
  ),
  PromotionType.CUSTOMIZE: PromotionData(
    type: PromotionType.CUSTOMIZE,
    idLabel: "Kustomisasi",
    enLabel: "Customize Promotion",
    icon: Icons.settings,
  ),
  PromotionType.LIFESTYLE: PromotionData(
    type: PromotionType.LIFESTYLE,
    idLabel: "Gaya Hidup",
    enLabel: "Lifestyle Discount",
    icon: Icons.style,
  ),
  PromotionType.FLASH_SALE: PromotionData(
    type: PromotionType.FLASH_SALE,
    idLabel: "Flash Sale",
    enLabel: "Flash Sale Program",
    icon: Icons.bolt,
  ),
  PromotionType.GIVEAWAY: PromotionData(
    type: PromotionType.GIVEAWAY,
    idLabel: "Hadiah",
    enLabel: "Social Media Giveaway",
    icon: Icons.redeem,
  ),
  PromotionType.FREE_SHIPPING: PromotionData(
    type: PromotionType.FREE_SHIPPING,
    idLabel: "Gratis Ongkir",
    enLabel: "Free Shipping",
    icon: Icons.local_shipping,
  ),
  PromotionType.FREE_SAMPLES: PromotionData(
    type: PromotionType.FREE_SAMPLES,
    idLabel: "Sampel Gratis",
    enLabel: "Free Sample",
    icon: Icons.category,
  ),
  PromotionType.FREE_GIFT: PromotionData(
    type: PromotionType.FREE_GIFT,
    idLabel: "Hadiah Gratis",
    enLabel: "Free Gift with Purchase",
    icon: Icons.card_giftcard,
  ),
  PromotionType.HOLIDAY: PromotionData(
    type: PromotionType.HOLIDAY,
    idLabel: "Promo Hari Raya",
    enLabel: "Holiday Promotion",
    icon: Icons.celebration,
  ),
};

// promotion_state.dart

class PromotionState {
  final PromotionType? selectedPromotionType;
  final bool isEnglish;
  final Map<String, dynamic> formData;

  PromotionState({
    this.selectedPromotionType,
    this.isEnglish = false,
    Map<String, dynamic>? formData,
  }) : formData = formData ?? {};

  PromotionState copyWith({
    PromotionType? selectedPromotionType,
    bool? isEnglish,
    Map<String, dynamic>? formData,
  }) {
    return PromotionState(
      selectedPromotionType:
          selectedPromotionType ?? this.selectedPromotionType,
      isEnglish: isEnglish ?? this.isEnglish,
      formData: formData ?? this.formData,
    );
  }
}

class PromotionNotifier extends StateNotifier<PromotionState> {
  PromotionNotifier() : super(PromotionState());

  void selectPromotionType(PromotionType type) {
    state = state.copyWith(selectedPromotionType: type, formData: {});
  }

  void toggleLanguage() {
    state = state.copyWith(isEnglish: !state.isEnglish);
  }

  void updateFormData(Map<String, dynamic> data) {
    final updatedFormData = Map<String, dynamic>.from(state.formData)
      ..addAll(data);
    state = state.copyWith(formData: updatedFormData);
  }
}

final promotionProvider =
    StateNotifierProvider<PromotionNotifier, PromotionState>((ref) {
      return PromotionNotifier();
    });

// promotion_builder_screen.dart

class PromotionBuilderScreen extends ConsumerWidget {
  const PromotionBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(promotionProvider);
    final notifier = ref.read(promotionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEnglish ? 'Promotion Builder' : 'Pembuat Promosi'),
        actions: [
          IconButton(
            icon: Icon(state.isEnglish ? Icons.language : Icons.translate),
            onPressed: () => notifier.toggleLanguage(),
            tooltip: state.isEnglish
                ? 'Switch to Indonesian'
                : 'Switch to English',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.isEnglish
                    ? 'Select promotion type to start building'
                    : 'Pilih tipe promosi untuk mulai membangun',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: state.selectedPromotionType == null
                  ? _buildPromotionTypeGrid(context, state, notifier)
                  : PromotionForm(promotionType: state.selectedPromotionType!),
            ),
          ],
        ),
      ),
      floatingActionButton: state.selectedPromotionType != null
          ? FloatingActionButton(
              onPressed: () {
                notifier.selectPromotionType(state.selectedPromotionType!);
                _showSavedPromotionDialog(context, state);
              },
              child: const Icon(Icons.save),
              tooltip: state.isEnglish ? 'Save Promotion' : 'Simpan Promosi',
            )
          : null,
    );
  }

  Widget _buildPromotionTypeGrid(
    BuildContext context,
    PromotionState state,
    PromotionNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: PromotionType.values.length,
        itemBuilder: (context, index) {
          final type = PromotionType.values[index];
          final data = promotionsData[type]!;

          return InkWell(
            onTap: () => notifier.selectPromotionType(type),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      data.icon,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isEnglish ? data.enLabel : data.idLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSavedPromotionDialog(BuildContext context, PromotionState state) {
    final promotionName = state.isEnglish
        ? promotionsData[state.selectedPromotionType]!.enLabel
        : promotionsData[state.selectedPromotionType]!.idLabel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(state.isEnglish ? 'Promotion Saved' : 'Promosi Tersimpan'),
        content: Text(
          state.isEnglish
              ? 'Your $promotionName promotion has been saved successfully.'
              : 'Promosi $promotionName Anda telah berhasil disimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(state.isEnglish ? 'OK' : 'Baik'),
          ),
        ],
      ),
    );
  }
}

class PromotionForm extends ConsumerWidget {
  final PromotionType promotionType;

  const PromotionForm({Key? key, required this.promotionType})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(promotionProvider);
    final notifier = ref.read(promotionProvider.notifier);
    final promotionData = promotionsData[promotionType]!;
    final isEnglish = state.isEnglish;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        promotionData.icon,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish
                                  ? promotionData.enLabel
                                  : promotionData.idLabel,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEnglish
                                  ? 'Configure promotion details below'
                                  : 'Konfigurasi detail promosi di bawah ini',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            isEnglish ? 'Basic Information' : 'Informasi Dasar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: InputDecoration(
              labelText: isEnglish ? 'Promotion Name' : 'Nama Promosi',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.campaign),
            ),
            onChanged: (value) => notifier.updateFormData({'name': value}),
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: InputDecoration(
              labelText: isEnglish ? 'Description' : 'Deskripsi',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: (value) =>
                notifier.updateFormData({'description': value}),
          ),
          const SizedBox(height: 24),

          Text(
            isEnglish ? 'Promotion Details' : 'Detail Promosi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildPromotionTypeSpecificFields(context, state, notifier),

          const SizedBox(height: 24),

          Text(
            isEnglish ? 'Schedule' : 'Jadwal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Start Date' : 'Tanggal Mulai',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      notifier.updateFormData({
                        'startDate': date.toIso8601String(),
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'End Date' : 'Tanggal Berakhir',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      notifier.updateFormData({
                        'endDate': date.toIso8601String(),
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () =>
                notifier.selectPromotionType(state.selectedPromotionType!),
            icon: const Icon(Icons.check),
            label: Text(isEnglish ? 'Apply Changes' : 'Terapkan Perubahan'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () =>
                notifier.selectPromotionType(PromotionType.values.first),
            icon: const Icon(Icons.arrow_back),
            label: Text(
              isEnglish ? 'Back to Promotion Types' : 'Kembali ke Tipe Promosi',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPromotionTypeSpecificFields(
    BuildContext context,
    PromotionState state,
    PromotionNotifier notifier,
  ) {
    final isEnglish = state.isEnglish;

    switch (promotionType) {
      case PromotionType.DISCOUNT:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish
                    ? 'Discount Percentage'
                    : 'Persentase Diskon',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  notifier.updateFormData({'discountPercent': value}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish
                    ? 'Minimum Purchase (Optional)'
                    : 'Pembelian Minimum (Opsional)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_cart),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  notifier.updateFormData({'minimumPurchase': value}),
            ),
          ],
        );

      case PromotionType.COUPON:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish ? 'Coupon Code' : 'Kode Kupon',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.code),
              ),
              onChanged: (value) =>
                  notifier.updateFormData({'couponCode': value}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish ? 'Discount Amount' : 'Jumlah Diskon',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  notifier.updateFormData({'discountAmount': value}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: isEnglish ? 'Discount Type' : 'Tipe Diskon',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.discount),
              ),
              items: [
                DropdownMenuItem(
                  value: 'percentage',
                  child: Text(isEnglish ? 'Percentage' : 'Persentase'),
                ),
                DropdownMenuItem(
                  value: 'fixed',
                  child: Text(isEnglish ? 'Fixed Amount' : 'Jumlah Tetap'),
                ),
              ],
              onChanged: (value) =>
                  notifier.updateFormData({'discountType': value}),
            ),
          ],
        );

      case PromotionType.POINT:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish
                    ? 'Points per Purchase'
                    : 'Poin per Pembelian',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.stars),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  notifier.updateFormData({'pointsPerPurchase': value}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish
                    ? 'Points Redemption Value'
                    : 'Nilai Tukar Poin',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.swap_horiz),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  notifier.updateFormData({'pointsRedemptionValue': value}),
            ),
          ],
        );

      case PromotionType.BOGO:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: isEnglish
                    ? 'Buy X Get Y Type'
                    : 'Tipe Beli X Dapat Y',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_bag),
              ),
              items: [
                DropdownMenuItem(
                  value: 'same',
                  child: Text(
                    isEnglish
                        ? 'Buy X Get Same Item Free'
                        : 'Beli X Dapat Item Sama Gratis',
                  ),
                ),
                DropdownMenuItem(
                  value: 'different',
                  child: Text(
                    isEnglish
                        ? 'Buy X Get Different Item'
                        : 'Beli X Dapat Item Berbeda',
                  ),
                ),
                DropdownMenuItem(
                  value: 'discount',
                  child: Text(
                    isEnglish
                        ? 'Buy X Get Discount on Y'
                        : 'Beli X Dapat Diskon untuk Y',
                  ),
                ),
              ],
              onChanged: (value) =>
                  notifier.updateFormData({'bogoType': value}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: isEnglish ? 'Buy Quantity' : 'Jumlah Beli',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.add_shopping_cart),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        notifier.updateFormData({'buyQuantity': value}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: isEnglish ? 'Get Quantity' : 'Jumlah Dapat',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.redeem),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        notifier.updateFormData({'getQuantity': value}),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish ? 'Promotion Value' : 'Nilai Promosi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => notifier.updateFormData({'value': value}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: isEnglish ? 'Promotion Details' : 'Detail Promosi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.details),
              ),
              maxLines: 3,
              onChanged: (value) =>
                  notifier.updateFormData({'promotionDetails': value}),
            ),
          ],
        );
    }
  }
}

// main.dart

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promotion Builder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const PromotionBuilderScreen(),
    );
  }
}
