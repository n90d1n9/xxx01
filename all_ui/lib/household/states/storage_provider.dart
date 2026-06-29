// Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

final storageProvider = Provider((ref) => StorageService());
