import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/barcode_services.dart';

final barcodeServiceProvider = Provider(
  (ref) => BarcodeService(onBarcodeDetected: (barcode) {}),
);
