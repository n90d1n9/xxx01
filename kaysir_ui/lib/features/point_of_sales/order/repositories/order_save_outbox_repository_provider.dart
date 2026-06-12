import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'order_save_outbox_repository.dart';

export 'order_save_outbox_repository.dart';

final posOrderSaveOutboxRepositoryProvider =
    Provider<POSOrderSaveOutboxRepository>((ref) {
      return POSOrderSaveOutboxRepository(
        store: LocalDbPOSOrderSaveOutboxSnapshotStore(),
      );
    });
