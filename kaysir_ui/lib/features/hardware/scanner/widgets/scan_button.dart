import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ScanButtonWidget extends ConsumerStatefulWidget {
  final void Function(String) onScan;

  const ScanButtonWidget({super.key, required this.onScan});

  @override
  ConsumerState<ScanButtonWidget> createState() => _ScanButtonWidgetState();
}

class _ScanButtonWidgetState extends ConsumerState<ScanButtonWidget> {
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    final scanner = ref.read(scannerProvider);
    await scanner.initializeScanner();

    _scanSubscription = scanner.scanStream.listen((code) {
      widget.onScan(code);
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () async {
        final scanner = ref.read(scannerProvider);
        await scanner.startScanning();
      },
    );
  }
}
