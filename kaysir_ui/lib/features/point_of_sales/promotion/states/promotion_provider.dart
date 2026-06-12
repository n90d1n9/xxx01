import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/states/terminal_provider.dart';
import '../models/promotion.dart';

final promotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getActivePromotions();
});
