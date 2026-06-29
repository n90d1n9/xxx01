import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceType { mobile, tablet, desktop }

final deviceTypeProvider = StateProvider<DeviceType>(
  (ref) => DeviceType.desktop,
);
