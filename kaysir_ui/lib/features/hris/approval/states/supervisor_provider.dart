/* import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/supervisor.dart';

final supervisorProvider =
    StateNotifierProvider<SupervisorNotifier, AsyncValue<void>>((ref) {
  return SupervisorNotifier(ref);
});

class SupervisorNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SupervisorNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<bool> requestApproval({
    required String actionType,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();
    try {
      final securityService = ref.read(securityProvider);
      final currentUser = ref.read(authProvider).user;

      final action = SupervisorAction(
        id: const Uuid().v4(),
        actionType: actionType,
        requestedBy: currentUser.id,
        requestedAt: DateTime.now(),
        reason: reason,
        metadata: metadata,
      );

      final approved = await showDialog<bool>(
        context: ref.read(navigatorKeyProvider).currentContext!,
        barrierDismissible: false,
        builder: (context) => SupervisorApprovalDialog(action: action),
      );

      state = const AsyncValue.data(null);
      return approved ?? false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
 */
