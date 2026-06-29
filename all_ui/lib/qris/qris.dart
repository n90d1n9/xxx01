import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// State notifier for QRIS payment
class QRISPaymentNotifier extends StateNotifier<QRISPaymentState> {
  QRISPaymentNotifier() : super(QRISPaymentState.initial());

  void updateAmount(String amount) {
    if (amount.isEmpty) {
      state = state.copyWith(amount: "0", isValidAmount: false);
      return;
    }

    // Remove non-numeric characters and convert to double
    final cleanAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    final numericAmount = double.tryParse(cleanAmount) ?? 0;

    state = state.copyWith(
      amount: cleanAmount,
      isValidAmount: numericAmount >= 1000, // Minimum amount 1,000 IDR
    );
  }

  void setMerchant(String merchantName, String merchantId) {
    state = state.copyWith(merchantName: merchantName, merchantId: merchantId);
  }

  Future<void> processPayment() async {
    if (!state.isValidAmount) return;

    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Success response simulation
    final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';

    state = state.copyWith(
      isLoading: false,
      isSuccess: true,
      transactionId: transactionId,
    );
  }

  void reset() {
    state = QRISPaymentState.initial();
  }
}

// State for QRIS payment
class QRISPaymentState {
  final String amount;
  final bool isValidAmount;
  final String merchantName;
  final String merchantId;
  final bool isLoading;
  final bool isSuccess;
  final String transactionId;

  QRISPaymentState({
    required this.amount,
    required this.isValidAmount,
    required this.merchantName,
    required this.merchantId,
    required this.isLoading,
    required this.isSuccess,
    required this.transactionId,
  });

  factory QRISPaymentState.initial() {
    return QRISPaymentState(
      amount: "0",
      isValidAmount: false,
      merchantName: "Toko Sumber Makmur",
      merchantId: "ID1029384756",
      isLoading: false,
      isSuccess: false,
      transactionId: "",
    );
  }

  QRISPaymentState copyWith({
    String? amount,
    bool? isValidAmount,
    String? merchantName,
    String? merchantId,
    bool? isLoading,
    bool? isSuccess,
    String? transactionId,
  }) {
    return QRISPaymentState(
      amount: amount ?? this.amount,
      isValidAmount: isValidAmount ?? this.isValidAmount,
      merchantName: merchantName ?? this.merchantName,
      merchantId: merchantId ?? this.merchantId,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}

// Providers
final qrisPaymentProvider =
    StateNotifierProvider<QRISPaymentNotifier, QRISPaymentState>(
      (ref) => QRISPaymentNotifier(),
    );

// Format currency
String formatCurrency(String value) {
  if (value.isEmpty) return "Rp 0";

  final number = int.tryParse(value) ?? 0;
  final format = number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  return "Rp $format";
}

class QRISPaymentScreen extends ConsumerWidget {
  const QRISPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qrisPaymentProvider);
    final notifier = ref.read(qrisPaymentProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "QRIS Payment",
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          state.isSuccess
              ? _buildSuccessScreen(context, state)
              : _buildPaymentForm(context, state, notifier),
    );
  }

  Widget _buildPaymentForm(
    BuildContext context,
    QRISPaymentState state,
    QRISPaymentNotifier notifier,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMerchantInfo(state),
            const SizedBox(height: 32),
            _buildAmountInput(context, state, notifier),
            const SizedBox(height: 32),
            _buildPaymentButton(context, state, notifier),
            const SizedBox(height: 24),
            _buildQRISInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantInfo(QRISPaymentState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Merchant",
            style: TextStyle(color: Color(0xFF718096), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            state.merchantName,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ID: ${state.merchantId}",
            style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(
    BuildContext context,
    QRISPaymentState state,
    QRISPaymentNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Amount",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            initialValue: state.amount != "0" ? state.amount : "",
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              prefixText: "Rp ",
              prefixStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              suffixText: state.isValidAmount ? "✓" : "",
              suffixStyle: const TextStyle(color: Colors.green, fontSize: 20),
            ),
            onChanged: (value) => notifier.updateAmount(value),
          ),
        ),
        if (!state.isValidAmount && state.amount != "0")
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Minimum amount is Rp 1.000",
              style: TextStyle(color: Color(0xFFE53E3E), fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentButton(
    BuildContext context,
    QRISPaymentState state,
    QRISPaymentNotifier notifier,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            state.isValidAmount && !state.isLoading
                ? () => notifier.processPayment()
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C51BF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            state.isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  "Pay ${formatCurrency(state.amount)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildQRISInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBD38D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QRIS Payment Information",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "This payment uses QRIS - Indonesian Standard QR Code for secure and interoperable transactions.",
                  style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, QRISPaymentState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF38A169),
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Payment Successful!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your payment of ${formatCurrency(state.amount)} has been processed",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildReceiptRow("Merchant", state.merchantName),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Transaction ID", state.transactionId),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Date", _formatDate(DateTime.now())),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Amount", formatCurrency(state.amount)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C51BF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Share receipt functionality
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, color: Color(0xFF4C51BF), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Share Receipt",
                    style: TextStyle(
                      color: Color(0xFF4C51BF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonth(date.month)} ${date.year}, ${_formatTime(date)}";
  }

  String _getMonth(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}

// Main app for demo purposes
class QRISPaymentApp extends StatelessWidget {
  const QRISPaymentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'QRIS Payment',
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Poppins'),
        home: const QRISPaymentScreen(),
      ),
    );
  }
}

void main() {
  runApp(const QRISPaymentApp());
}
