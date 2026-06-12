// AI Service Provider
import 'package:flutter_riverpod/legacy.dart';

import '../service/local_notification.dart';

final aiSchedulingServiceProvider = Provider((ref) => AISchedulingService());
