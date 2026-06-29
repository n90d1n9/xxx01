import 'package:flutter_riverpod/legacy.dart';

import '../models/grid_settings_provider.dart';

final gridSettingsProvider = StateProvider<GridSettings>(
  (ref) => GridSettings(),
);
