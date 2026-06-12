import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/invoic_dummy.dart';

import '../models/customer.dart';

final customersProvider =
    StateNotifierProvider<CustomersNotifier, List<Customer>>((ref) {
      return CustomersNotifier();
    });

final customersProvider2 = FutureProvider<List<Customer>>((ref) {
  return Future.delayed(const Duration(seconds: 2), () => customerDummy);
});

final customersProvider3 =
    AsyncNotifierProvider<CustomersNotifier2, List<Customer>>(
      CustomersNotifier2.new,
    );
//                           id: '', name: 'Unknown'),

class CustomersNotifier2 extends AsyncNotifier<List<Customer>> {
  CustomersNotifier2();

  @override
  Future<List<Customer>> build() async {
    return Future.delayed(const Duration(seconds: 2), () => customerDummy);
  }

  void addCustomer(Customer customer) {
    state = AsyncValue.data([...state.value ?? [], customer]);
  }

  void updateCustomer(Customer updatedCustomer) {
    state = AsyncValue.data(
      (state.value ?? []).map((customer) {
        if (customer.id == updatedCustomer.id) {
          return updatedCustomer;
        }
        return customer;
      }).toList(),
    );
  }

  void removeCustomer(String id) {
    state = AsyncValue.data(
      (state.value ?? []).where((customer) => customer.id != id).toList(),
    );
  }
}

// Notifiers
class CustomersNotifier extends StateNotifier<List<Customer>> {
  CustomersNotifier() : super(customerDummy);

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void updateCustomer(Customer updatedCustomer) {
    state =
        state.map((customer) {
          if (customer.id == updatedCustomer.id) {
            return updatedCustomer;
          }
          return customer;
        }).toList();
  }

  void removeCustomer(String id) {
    state = state.where((customer) => customer.id != id).toList();
  }
}
