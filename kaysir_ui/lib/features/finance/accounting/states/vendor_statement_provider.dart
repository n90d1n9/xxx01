import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/vendor_statement_service.dart';

final vendorStatementServiceProvider = Provider<VendorStatementService>((ref) {
  return const VendorStatementService();
});
