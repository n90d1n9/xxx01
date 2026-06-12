import '../data/restaurant_demo_snapshot.dart';
import '../models/restaurant_models.dart';

typedef RestaurantSnapshotLoader =
    Future<RestaurantOperatingSnapshot?> Function();

abstract interface class RestaurantSnapshotRepository {
  Future<RestaurantOperatingSnapshot?> fetchSnapshot();
}

class DemoRestaurantSnapshotRepository implements RestaurantSnapshotRepository {
  const DemoRestaurantSnapshotRepository({
    this.snapshot = restaurantDemoSnapshot,
    this.delay = Duration.zero,
  });

  final RestaurantOperatingSnapshot? snapshot;
  final Duration delay;

  @override
  Future<RestaurantOperatingSnapshot?> fetchSnapshot() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return snapshot;
  }
}

class CallbackRestaurantSnapshotRepository
    implements RestaurantSnapshotRepository {
  const CallbackRestaurantSnapshotRepository(this.loader);

  final RestaurantSnapshotLoader loader;

  @override
  Future<RestaurantOperatingSnapshot?> fetchSnapshot() {
    return loader();
  }
}
