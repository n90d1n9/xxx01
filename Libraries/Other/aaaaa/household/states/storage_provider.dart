// Providers
import 'package:flutter_riverpod/legacy.dart';

import '../services/storage_service.dart';

final storageProvider = Provider((ref) => StorageService());
