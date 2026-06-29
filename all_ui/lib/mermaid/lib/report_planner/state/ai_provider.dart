// AI Service Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/local_notification.dart';

final aiSchedulingServiceProvider = Provider((ref) => AISchedulingService());
