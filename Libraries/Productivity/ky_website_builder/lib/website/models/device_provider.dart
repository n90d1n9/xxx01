import 'package:flutter_riverpod/legacy.dart';

enum DeviceType { mobile, tablet, desktop }

final deviceTypeProvider = StateProvider<DeviceType>(
  (ref) => DeviceType.desktop,
);
