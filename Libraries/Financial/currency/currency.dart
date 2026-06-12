import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

// Currency Data Model
class Currency {
  final String code;
  final String name;
  final String flag;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.symbol,
  });
}

// Exchange Rate Model
class ExchangeRate {
  final Map<String, double> rates;
  final DateTime timestamp;

  ExchangeRate({required this.rates, required this.timestamp});
}

// Conversion State
class ConversionState {
  final double amount;
  final Currency fromCurrency;
  final Currency toCurrency;
  final ExchangeRate? exchangeRate;
  final bool isLoading;
  final String? error;
  final bool isManualMode;
  final Map<String, double> manualRates;

  ConversionState({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    this.exchangeRate,
    this.isLoading = false,
    this.error,
    this.isManualMode = false,
    Map<String, double>? manualRates,
  }) : manualRates = manualRates ?? {};

  ConversionState copyWith({
    double? amount,
    Currency? fromCurrency,
    Currency? toCurrency,
    ExchangeRate? exchangeRate,
    bool? isLoading,
    String? error,
    bool? isManualMode,
    Map<String, double>? manualRates,
  }) {
    return ConversionState(
      amount: amount ?? this.amount,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isManualMode: isManualMode ?? this.isManualMode,
      manualRates: manualRates ?? this.manualRates,
    );
  }

  double get convertedAmount {
    if (isManualMode) {
      // Use manual rates if in manual mode
      double fromRate = manualRates[fromCurrency.code] ?? 1.0;
      double toRate = manualRates[toCurrency.code] ?? 1.0;
      return (amount / fromRate) * toRate;
    } else if (exchangeRate == null ||
        !exchangeRate!.rates.containsKey(toCurrency.code)) {
      return 0.0;
    } else {
      double fromRate = exchangeRate!.rates[fromCurrency.code] ?? 1.0;
      double toRate = exchangeRate!.rates[toCurrency.code] ?? 1.0;
      return (amount / fromRate) * toRate;
    }
  }

  String get lastUpdated {
    if (isManualMode) return "Using manual rates";
    if (exchangeRate == null) return "Not available";
    return DateFormat(
      'MMM dd, yyyy HH:mm',
    ).format(exchangeRate!.timestamp.toLocal());
  }
}

// Currency Repository
class CurrencyRepository {
  static final List<Currency> currencies = [
    Currency(code: "USD", name: "US Dollar", flag: "🇺🇸", symbol: "\$"),
    Currency(
      code: "IDR",
      name: "Indonesian Rupiah",
      flag: "🇮🇩",
      symbol: "Rp",
    ),
    Currency(code: "GBP", name: "British Pound", flag: "🇬🇧", symbol: "£"),
    Currency(code: "CNY", name: "Chinese Yuan", flag: "🇨🇳", symbol: "¥"),
    Currency(code: "JPY", name: "Japanese Yen", flag: "🇯🇵", symbol: "¥"),
    Currency(
      code: "SGD",
      name: "Singapore Dollar",
      flag: "🇸🇬",
      symbol: "S\$",
    ),
    Currency(code: "INR", name: "Indian Rupee", flag: "🇮🇳", symbol: "₹"),
    Currency(
      code: "MYR",
      name: "Malaysian Ringgit",
      flag: "🇲🇾",
      symbol: "RM",
    ),
    Currency(code: "AED", name: "UAE Dirham", flag: "🇦🇪", symbol: "د.إ"),
    Currency(code: "SAR", name: "Saudi Riyal", flag: "🇸🇦", symbol: "﷼"),
    Currency(code: "EUR", name: "Euro", flag: "🇪🇺", symbol: "€"),
    Currency(code: "CAD", name: "Canadian Dollar", flag: "🇨🇦", symbol: "C\$"),
    Currency(
      code: "AUD",
      name: "Australian Dollar",
      flag: "🇦🇺",
      symbol: "A\$",
    ),
    Currency(code: "KRW", name: "South Korean Won", flag: "🇰🇷", symbol: "₩"),
    Currency(code: "RUB", name: "Russian Ruble", flag: "🇷🇺", symbol: "₽"),
  ];

  // In a real app, replace this with your actual API key
  static const String apiKey = "YOUR_API_KEY";
  static const String baseUrl = "https://api.exchangerate.host/latest";

  Future<ExchangeRate> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = Map<String, double>.from(data['rates']);
        final timestamp = DateTime.parse(data['date'] + " 00:00:00Z");

        return ExchangeRate(rates: rates, timestamp: timestamp);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // For demo purposes, return mock data if API fails
      return _getMockExchangeRates();
    }
  }

  // Mock data in case the API call fails or for development
  ExchangeRate _getMockExchangeRates() {
    return ExchangeRate(
      rates: {
        "USD": 1.0,
        "IDR": 15600.0,
        "GBP": 0.78,
        "CNY": 7.1,
        "JPY": 149.2,
        "SGD": 1.33,
        "INR": 83.5,
        "MYR": 4.65,
        "AED": 3.67,
        "SAR": 3.75,
        "EUR": 0.91,
        "CAD": 1.35,
        "AUD": 1.48,
        "KRW": 1334.0,
        "RUB": 92.0,
      },
      timestamp: DateTime.now(),
    );
  }
}

// Providers
final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository();
});

final exchangeRateProvider = FutureProvider<ExchangeRate>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.fetchExchangeRates();
});

final conversionStateProvider =
    StateNotifierProvider<ConversionStateNotifier, ConversionState>((ref) {
      final repository = ref.watch(currencyRepositoryProvider);
      return ConversionStateNotifier(repository);
    });

// Notifier for Conversion State
class ConversionStateNotifier extends StateNotifier<ConversionState> {
  final CurrencyRepository repository;

  ConversionStateNotifier(this.repository)
    : super(
        ConversionState(
          amount: 1.0,
          fromCurrency: CurrencyRepository.currencies.firstWhere(
            (c) => c.code == "USD",
          ),
          toCurrency: CurrencyRepository.currencies.firstWhere(
            (c) => c.code == "EUR",
          ),
          isLoading: true,
        ),
      ) {
    _fetchExchangeRates();
  }

  void toggleManualMode() {
    final isManualMode = !state.isManualMode;

    // Initialize manual rates with current rates if toggling to manual mode
    Map<String, double>? manualRates = state.manualRates;
    if (isManualMode &&
        state.manualRates.isEmpty &&
        state.exchangeRate != null) {
      manualRates = Map.from(state.exchangeRate!.rates);
    }

    state = state.copyWith(
      isManualMode: isManualMode,
      manualRates: manualRates,
    );
  }

  void updateManualRate(String currencyCode, double rate) {
    final updatedRates = Map<String, double>.from(state.manualRates);
    updatedRates[currencyCode] = rate;
    state = state.copyWith(manualRates: updatedRates);
  }

  void resetManualRates() {
    if (state.exchangeRate != null) {
      state = state.copyWith(manualRates: Map.from(state.exchangeRate!.rates));
    }
  }

  Future<void> _fetchExchangeRates() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final rates = await repository.fetchExchangeRates();
      state = state.copyWith(exchangeRate: rates, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to fetch exchange rates: ${e.toString()}",
      );
    }
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void swapCurrencies() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
  }

  void setFromCurrency(Currency currency) {
    state = state.copyWith(fromCurrency: currency);
  }

  void setToCurrency(Currency currency) {
    state = state.copyWith(toCurrency: currency);
  }

  void refreshRates() {
    _fetchExchangeRates();
  }
}

// Custom Number Input Formatter
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    } else if (newValue.text == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    final RegExp regex = RegExp(
      r'^\d*\.?\d{0,' + decimalRange.toString() + r'}',
    );
    final String newString = regex.stringMatch(newValue.text) ?? '';

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

// Main Currency Converter Widget
class CurrencyConverter extends ConsumerWidget {
  const CurrencyConverter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversionStateProvider);
    final notifier = ref.read(conversionStateProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Currency Converter',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => notifier.refreshRates(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConverterBody(context, state, notifier),
    );
  }

  void _showManualRatesEditor(
    BuildContext context,
    ConversionState state,
    ConversionStateNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManualRatesEditorSheet(
        manualRates: state.manualRates,
        onRateUpdated: (code, rate) => notifier.updateManualRate(code, rate),
        onReset: () => notifier.resetManualRates(),
      ),
    );
  }

  Widget _buildConverterBody(
    BuildContext context,
    ConversionState state,
    ConversionStateNotifier notifier,
  ) {
    return Column(
      children: [
        _buildInfoCard(context, state),
        _buildModeToggle(context, state, notifier), // Add this line
        _buildAmountInput(context, state, notifier),
        _buildCurrencyCards(context, state, notifier),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, ConversionState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.fromCurrency.symbol,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.amount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.fromCurrency.code,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.toCurrency.symbol,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.convertedAmount.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.toCurrency.code,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Last updated: ${state.lastUpdated}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (state.error != null)
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(
    BuildContext context,
    ConversionState state,
    ConversionStateNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Switch(
                value: state.isManualMode,
                onChanged: (_) => notifier.toggleManualMode(),
                activeColor: Colors.blue,
              ),
              Text(
                "Manual Rates",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (state.isManualMode)
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit Rates"),
              onPressed: () => _showManualRatesEditor(context, state, notifier),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(
    BuildContext context,
    ConversionState state,
    ConversionStateNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Amount",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(
                  text: state.amount.toString(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    notifier.setAmount(double.parse(value));
                  } else {
                    notifier.setAmount(0);
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      state.fromCurrency.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 0,
                  ),
                  suffixText: state.fromCurrency.code,
                  suffixStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCards(
    BuildContext context,
    ConversionState state,
    ConversionStateNotifier notifier,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select currencies",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Colors.blue),
                      onPressed: () => notifier.swapCurrencies(),
                      tooltip: 'Swap currencies',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCurrencySelector(
                  context,
                  "From",
                  state.fromCurrency,
                  (Currency currency) => notifier.setFromCurrency(currency),
                ),
                const SizedBox(height: 16),
                _buildCurrencySelector(
                  context,
                  "To",
                  state.toCurrency,
                  (Currency currency) => notifier.setToCurrency(currency),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    String label,
    Currency selectedCurrency,
    Function(Currency) onCurrencySelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCurrencyPicker(
            context,
            selectedCurrency,
            onCurrencySelected,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  selectedCurrency.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCurrency.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedCurrency.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    Currency selectedCurrency,
    Function(Currency) onCurrencySelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        selectedCurrency: selectedCurrency,
        onCurrencySelected: (currency) {
          onCurrencySelected(currency);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Currency Picker Bottom Sheet
class _CurrencyPickerSheet extends StatefulWidget {
  final Currency selectedCurrency;
  final Function(Currency) onCurrencySelected;

  const _CurrencyPickerSheet({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late TextEditingController _searchController;
  List<Currency> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCurrencies = CurrencyRepository.currencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCurrencies = CurrencyRepository.currencies;
      });
      return;
    }

    setState(() {
      _filteredCurrencies = CurrencyRepository.currencies
          .where(
            (currency) =>
                currency.name.toLowerCase().contains(query.toLowerCase()) ||
                currency.code.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCurrencies,
              decoration: InputDecoration(
                hintText: 'Search currency',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected =
                    currency.code == widget.selectedCurrency.code;

                return ListTile(
                  leading: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    currency.code,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(currency.name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  tileColor: isSelected
                      ? Colors.blue.withValues(alpha: 0.1)
                      : null,
                  onTap: () => widget.onCurrencySelected(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Example App
class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Currency Converter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const CurrencyConverter(),
      ),
    );
  }
}

class _ManualRatesEditorSheet extends StatefulWidget {
  final Map<String, double> manualRates;
  final Function(String, double) onRateUpdated;
  final VoidCallback onReset;

  const _ManualRatesEditorSheet({
    super.key,
    required this.manualRates,
    required this.onRateUpdated,
    required this.onReset,
  });

  @override
  State<_ManualRatesEditorSheet> createState() =>
      _ManualRatesEditorSheetState();
}

class _ManualRatesEditorSheetState extends State<_ManualRatesEditorSheet> {
  late TextEditingController _searchController;
  List<Currency> _filteredCurrencies = [];
  Map<String, TextEditingController> _rateControllers = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCurrencies = CurrencyRepository.currencies;

    // Initialize text controllers for each currency
    for (var currency in CurrencyRepository.currencies) {
      final rate = widget.manualRates[currency.code] ?? 1.0;
      _rateControllers[currency.code] = TextEditingController(
        text: rate.toString(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rateControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _filterCurrencies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCurrencies = CurrencyRepository.currencies;
      });
      return;
    }

    setState(() {
      _filteredCurrencies = CurrencyRepository.currencies
          .where(
            (currency) =>
                currency.name.toLowerCase().contains(query.toLowerCase()) ||
                currency.code.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  "Edit Exchange Rates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_outlined, size: 16),
                  label: const Text("Reset"),
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCurrencies,
              decoration: InputDecoration(
                hintText: 'Search currency',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Currency",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Rate to USD",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final controller = _rateControllers[currency.code]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Text(
                              currency.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currency.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 6),
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              widget.onRateUpdated(
                                currency.code,
                                double.parse(value),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Apply Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        title: 'Currency Converter',

        home: CurrencyConverter(),
      ),
    ),
  );
}
