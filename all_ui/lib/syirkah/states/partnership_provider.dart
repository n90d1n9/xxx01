import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/partnership.dart';
import '../services/partnership_service.dart';

final partnershipServiceProvider = Provider<PartnershipService>((ref) {
  return PartnershipService();
});

final userPartnershipsProvider =
    FutureProvider.family<List<Partnership>, String>((ref, userId) {
      final partnershipService = ref.watch(partnershipServiceProvider);
      return partnershipService.getPartnerships(userId);
    });
