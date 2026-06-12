import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/customer.dart';
import '../services/api_services.dart';
import 'terminal_provider.dart';

class CustomersNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final ApiService _apiService;

  CustomersNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final customers = await _apiService.getCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      final customers = await _apiService.searchCustomers(query);
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, AsyncValue<List<Customer>>>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return CustomersNotifier(apiService);
    });
