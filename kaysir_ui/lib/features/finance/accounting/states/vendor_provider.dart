import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../invoic_dummy.dart';
import '../models/vendor.dart';

final vendorsProvider = StateNotifierProvider<VendorsNotifier, List<Vendor>>((
  ref,
) {
  return VendorsNotifier();
});

class VendorsNotifier extends StateNotifier<List<Vendor>> {
  VendorsNotifier() : super(vendorDummy);

  void addVendor(Vendor vendor) {
    state = [...state, vendor];
  }

  void updateVendor(Vendor updatedVendor) {
    state = [
      for (final vendor in state)
        if (vendor.id == updatedVendor.id) updatedVendor else vendor,
    ];
  }

  void removeVendor(String id) {
    state = state.where((vendor) => vendor.id != id).toList();
  }
}
